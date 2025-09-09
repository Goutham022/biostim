import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:io' show HttpClient;        // <- for HttpClient()
import 'dart:math' as math;
import 'dart:async';
import 'dart:convert';

class FootDropRehabPage extends StatefulWidget {
  const FootDropRehabPage({super.key});

  @override
  State<FootDropRehabPage> createState() => _FootDropRehabPageState();
}

class ComplementaryRollFilter {
  // ---- Tunables ----
  final double minCutoffHz;      // accel blend cutoff (0.5–2 Hz typical)
  final double accLsbPerG;       // e.g. MPU6050: ±2g -> 16384, ±4g -> 8192
  final double gyroLsbPerDps;    // e.g. MPU6050: ±250 dps -> 131, ±500 -> 65.5
  final double axBias, ayBias, azBias;   // accel biases in raw LSB (or g*LSB)
  final double gxBiasDps;                // gyro X bias in deg/s

  ComplementaryRollFilter({
    this.minCutoffHz = 1.0,
    required this.accLsbPerG,
    required this.gyroLsbPerDps,
    this.axBias = 0.0,
    this.ayBias = 0.0,
    this.azBias = 0.0,
    this.gxBiasDps = 0.0,
  });

  double _rollDeg = 0.0;
  bool _init = false;

  /// Returns current roll in degrees.
  double update({
    required int? axRaw,
    required int? ayRaw,
    required int? azRaw,
    required int? gxRaw,
    required int? gyRaw, // unused for roll but kept for signature symmetry
    required int? gzRaw, // unused
    required double dt,
  }) {
    if (axRaw == null || ayRaw == null || azRaw == null || gxRaw == null || dt <= 0) {
      return _rollDeg; // keep last value if data is missing
    }

    // Convert raw -> physical units
    final ax = (axRaw - axBias) / accLsbPerG;   // g
    final ay = (ayRaw - ayBias) / accLsbPerG;   // g
    final az = (azRaw - azBias) / accLsbPerG;   // g
    final gxDps = (gxRaw / gyroLsbPerDps) - gxBiasDps; // deg/s

    // Accel tilt (roll) from gravity (normalize helps under varying g)
    final norm = math.sqrt(ax*ax + ay*ay + az*az);
    final nay = ay / (norm == 0 ? 1 : norm);
    final naz = az / (norm == 0 ? 1 : norm);
    final accRollDeg = math.atan2(nay, naz) * 180.0 / math.pi;

    if (!_init) {
      _rollDeg = accRollDeg; _init = true;
      return _rollDeg;
    }

    // Complementary blend: high-pass gyro + low-pass accel
    final a = _alpha(dt); // ~ tau/(tau+dt)
    _rollDeg = a * (_rollDeg + gxDps * dt) + (1 - a) * accRollDeg;
    return _rollDeg;
  }

  double _alpha(double dt) {
    final tau = 1.0 / (2.0 * math.pi * minCutoffHz); // seconds
    return tau / (tau + dt);
  }

  void reset([double? toDeg]) { _init = false; if (toDeg != null) _rollDeg = toDeg; }
  double get valueDeg => _rollDeg;
}

class ZeroOrderHold {
  final Stopwatch clock;
  Timer? _timer;
  double? _y;          // last value
  double? _lastTSec;   // when last sample arrived (sec)

  ZeroOrderHold(this.clock);

  // Call this whenever a new filtered sample arrives
  void add(double y) {
    _y = y;
    _lastTSec = clock.elapsedMicroseconds / 1e6;
  }

  // Start rendering at a fixed rate (e.g., 16 Hz)
  void start({double rateHz = 16, required void Function(double) sink, double? staleSec}) {
    _timer?.cancel();
    final periodMs = (1000 / rateHz).round();
    _timer = Timer.periodic(Duration(milliseconds: periodMs), (_) {
      final y = _y;
      if (y == null) return;

      // Optional: skip if value is too old (no new samples in a while)
      if (staleSec != null && _lastTSec != null) {
        final now = clock.elapsedMicroseconds / 1e6;
        if ((now - _lastTSec!) > staleSec) return;
      }
      sink(y); // plot the held value
    });
  }

  void stop() => _timer?.cancel();
}


class _FootDropRehabPageState extends State<FootDropRehabPage> with TickerProviderStateMixin {

  double angleValue = -12.5;
  double triggerAngleValue = 0.0;

  // Overlay rotation state
  final ValueNotifier<double> overlayAngleRad = ValueNotifier(0.0);
  AnimationController? _animationController;
  Animation<double>? _rotationAnimation;

  final List<int> durationOptions = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  final List<int> pulseWidthOptions = [100, 200, 300, 400, 500];
  
  bool _showBolt = false;

  final rollFilter = ComplementaryRollFilter(
    minCutoffHz: 1.0,     // tune 0.5–2 Hz
    accLsbPerG: 2048.0,   // ICM-42670 default ±16 g
    gyroLsbPerDps: 16.4,  // ICM-42670 default ±2000 dps
  );

  final Stopwatch _mono = Stopwatch();
  int? _lastUs;
  late final ZeroOrderHold _zoh;
  late http.Client _client;
  Duration httpTimeout = const Duration(milliseconds: 800);
  Timer? _pollTimer;
  bool _inFlight = false;
  bool _isRunning = false;
  double? _prevLiveForThreshold;
  int _stimDuration = 1;
  int stimulationValue = 0;
  double _calibrationOffset = 0.0;
  double triggerAngleDeg = 0.0;
  double rollDeg = 0.0;
  Timer? _clockTimer;
  int _seconds = 0;
  int _steps = 0;
  int selectedDuration = 1;
  int selectedPulseWidth = 100;

  void flashBolt(int dura) {
    if (!mounted) return;
    setState(() => _showBolt = true);
    Future.delayed(Duration(seconds : dura), () {
    if (!mounted) return;
      setState(() => _showBolt = false);
    });
  }

  @override
  void initState() {
    super.initState();
    _client = http.Client();
    _mono.start();
    _zoh = ZeroOrderHold(_mono);
    _zoh.start(
      rateHz: 16,                          // try 16; or 30/60
      staleSec: 3.0,                       // optional
      sink: (y) => refreshLegAnimation(y),                // your chart update
    );
    _pollTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _fetchAngleFromESP();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _zoh.stop();
    _client.close();
    super.dispose();
  }

  Future<bool> TriggerStimulation(int strength, int duration) async {
  try {
    final resp = await http.post(
      Uri.parse('http://192.168.4.1/Trigger'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'strength': strength, 'duration': duration}),
    ).timeout(const Duration(milliseconds: 800));

    return resp.statusCode == 200 && resp.body.contains('Data received');
  } catch (e) {
    print('POST /Trigger failed: $e');
    return false;
  }
}

  Future<bool> SendPulseWidth(int pulsewidth) async {
    try {
      final resp = await http.post(
        Uri.parse('http://192.168.4.1/pulseWidth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'PulseWidth': pulsewidth/10,}),
      ).timeout(const Duration(milliseconds: 800));

      return resp.statusCode == 200 && resp.body.contains('Data received');
    } catch (e) {
      print('POST /pulseWidth failed: $e');
      return false;
    }
  }

  Future<void> _fetchAngleFromESP() async {
    if (_inFlight) return;
    _inFlight = true;
    try {
      final headers = const {'Connection': 'keep-alive'};
      final results = await Future.wait([
        _client.get(Uri.parse('http://192.168.4.1/RawAccel'), headers: headers).timeout(httpTimeout),
        _client.get(Uri.parse('http://192.168.4.1/Roll'),     headers: headers).timeout(httpTimeout),
      ]);
      final res  = results[0];
      final res2 = results[1];

      if (res.statusCode != 200 || res2.statusCode != 200) {
        print("disconnected");
        return;
      }
      //print(res.body);
      final obj = jsonDecode(res.body) as Map<String, dynamic>;
      final obj2 = jsonDecode(res2.body) as Map<String, dynamic>;
      final int? axRaw = (obj['accel_x'] as num?)?.toInt();
      final int? ayRaw = (obj['accel_y'] as num?)?.toInt();
      final int? azRaw = (obj['accel_z'] as num?)?.toInt();
      final int? gxRaw = (obj2['gyro_x'] as num?)?.toInt();
      final int? gyRaw = (obj2['gyro_y'] as num?)?.toInt();
      final int? gzRaw = (obj2['gyro_z'] as num?)?.toInt();
      
      final monoUs = _mono.elapsedMicroseconds;
      double dt = (_lastUs == null) ? 0.0 : (monoUs - _lastUs!) / 1e6;
      _lastUs = monoUs;
      if (dt <= 0) return;            // ignore nonsense
        if (dt > 2.5) {                 // big stall -> re-seed next time
          rollFilter.reset();
        return;
      }

        final newRollDeg = rollFilter.update(
          axRaw: axRaw, ayRaw: ayRaw, azRaw: azRaw,
          gxRaw: gxRaw, gyRaw: gyRaw, gzRaw: gzRaw,
          dt: dt,
      );

    if (ayRaw != null && azRaw != null) {
      //print('dt=${dt.toStringAsFixed(4)} s');
        //final roll = getRollX(ayRaw, azRaw);
        //final rolldp = (roll * 10).round() / 10;
        //appendDataToChart(rollDeg);
        //_zoh.add(newRollDeg);
        final adjusted = newRollDeg - _calibrationOffset;
        if (_isRunning) ThresholdDetection(adjusted, triggerAngleDeg);
        _zoh.add(adjusted);
        if (mounted) setState(() => rollDeg = newRollDeg);
        print(rollDeg);
    }

    } catch (e) {
      print('fetch error: $e');
    } finally {
      _inFlight = false;
    }
  }

  void ThresholdDetection(double liveAngle, double triggerAngle) async {
  // Detect a one-time crossing past the trigger.
  // For positive trigger: print when live crosses upward (prev < trig, now >= trig).
  // For negative trigger: print when live crosses downward (prev > trig, now <= trig).
    if(triggerAngle > -1 && triggerAngle < 1) return;
    final prev = _prevLiveForThreshold;
    if (prev != null) {
      final prevDiff = prev - triggerAngle;
      final currDiff = liveAngle - triggerAngle;

      if (triggerAngle >= 0) {
        if (prevDiff < 0 && currDiff >= 0) {
          _steps++;
          final ok = await TriggerStimulation(stimulationValue, _stimDuration);
          if(ok) flashBolt(_stimDuration);
          print('Threshold reached: live ${liveAngle.toStringAsFixed(1)} >= trigger ${triggerAngle.toStringAsFixed(1)}');
        }
      } else {
        if (prevDiff > 0 && currDiff <= 0) {
          _steps++;
          final ok = await TriggerStimulation(stimulationValue, _stimDuration);
          if(ok) flashBolt(_stimDuration);
          print('Threshold reached: live ${liveAngle.toStringAsFixed(1)} <= trigger ${triggerAngle.toStringAsFixed(1)}');
        }
      }
    }
    _prevLiveForThreshold = liveAngle;
  }

  void refreshLegAnimation (double angleDeg)
  {
    if(angleDeg < -90 || angleDeg > 90) return;
    if(!mounted) return;
    setState(() {
      //setOverlayAngleDegrees(rollDeg - _calibrationOffset);
      setOverlayAngleDegrees(angleDeg);
    });
  }

  // Helper methods for overlay rotation
  void setOverlayAngleDegrees(double deg) {
    overlayAngleRad.value = deg * (3.14159 / 180.0); // Convert degrees to radians
  }

  void setOverlayAngleRadians(double rad) {
    overlayAngleRad.value = rad;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Foot Drop Rehab',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 16),


              // Top Card (Stacked Images)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTablet = constraints.maxWidth > 600;
                  final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

                  // Card width logic
                  double maxCardWidth = isTablet ? 900 : 1200; // Limit card width on tablet
                  double cardWidth = constraints.maxWidth < maxCardWidth
                      ? constraints.maxWidth
                      : maxCardWidth;

                  // Card height logic (increased for phone based on screen size)
                  double cardHeight;
                  if (isTablet) {
                    cardHeight = isLandscape ? 260 : 320; // Increased heights for tablet
                  } else {
                    // For phone, set height as a percentage of screen height, min 180, max 260
                    double screenHeight = MediaQuery.of(context).size.height;
                    cardHeight = (screenHeight * 0.22).clamp(180.0, 260.0);
                  }

                  // In landscape, further limit height to avoid overflow
                  if (isLandscape) {
                    double availableHeight = MediaQuery.of(context).size.height * 0.5;
                    if (cardHeight > availableHeight) {
                      cardHeight = availableHeight;
                    }
                  }

                  // Image width logic (decreased a little)
                  double imageMaxWidth = isTablet
                      ? (cardWidth * 0.70).clamp(0, 500)
                      : 500;
                  double imageWidth = imageMaxWidth < cardWidth ? imageMaxWidth : cardWidth;

                  return Center(
                    child: Container(
                      width: cardWidth,
                      height: cardHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(18, 0, 0, 0),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: SizedBox(
                          width: imageWidth,
                          height: cardHeight,
                          child: Container(
                            width: imageWidth,
                            height: cardHeight,
                            // Removed invalid 'borderRadius' parameter
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/home_tab/footdrop/Background.png'),
                                         fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                // Rotatable overlay image with anchor point moved a little down
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: ValueListenableBuilder<double>(
                                    valueListenable: overlayAngleRad,
                                    builder: (context, angle, child) {
                                      // Define insets for clearance from card edges
                                      const double sideInset = 16.0;
                                      const double topInset = 12.0;
                                      const double bottomInset = 12.0;
                                      
                                      // Calculate available space for the overlay
                                      final double innerW = imageWidth - (2 * sideInset);
                                      final double innerH = cardHeight - topInset - bottomInset;

                                      // Move the anchor point a little down (e.g., 10% from the top)
                                      const double anchorYOffset = 0.10; // 10% down from the top

                                      return SizedBox(
                                        width: innerW,
                                        height: innerH,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          alignment: Alignment.topCenter,
                                          child: RepaintBoundary(
                                            child: Transform.rotate(
                                              alignment: Alignment(0.0, -1.0 + 2 * anchorYOffset),
                                              angle: angle,
                                              child: Image.asset(
                                                'assets/images/home_tab/footdrop/leg.png',
                                                filterQuality: FilterQuality.high,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // // Debug slider for testing overlay rotation (only in debug mode)
              // if (kDebugMode) ...[
              //   const SizedBox(height: 16),
              //   Container(
              //     padding: const EdgeInsets.all(16),
              //     decoration: BoxDecoration(
              //       color: Colors.grey[100],
              //       borderRadius: BorderRadius.circular(12),
              //       border: Border.all(color: Colors.grey[300]!),
              //     ),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         const Text(
              //           'Debug: Overlay Rotation Test',
              //           style: TextStyle(
              //             fontFamily: 'Montserrat',
              //             fontSize: 14,
              //             fontWeight: FontWeight.w500,
              //             color: Colors.grey,
              //           ),
              //         ),
              //         const SizedBox(height: 8),
              //         Row(
              //           children: [
              //             const Text(
              //               '-90°',
              //               style: TextStyle(
              //                 fontFamily: 'Montserrat',
              //                 fontSize: 12,
              //                 color: Colors.grey,
              //               ),
              //             ),
              //             Expanded(
              //               child: Slider(
              //                 value: overlayAngleRad.value * (180.0 / 3.14159), // Convert radians to degrees
              //                 min: -90.0,
              //                 max: 90.0,
              //                 divisions: 180,
              //                 onChanged: (value) {
              //                   setOverlayAngleDegrees(value);
              //                 },
              //               ),
              //             ),
              //             const Text(
              //               '+90°',
              //               style: TextStyle(
              //                 fontFamily: 'Montserrat',
              //                 fontSize: 12,
              //                 color: Colors.grey,
              //               ),
              //             ),
              //           ],
              //         ),
              //         Center(
              //           child: Text(
              //             '${(overlayAngleRad.value * (180.0 / 3.14159)).toStringAsFixed(1)}°',
              //             style: const TextStyle(
              //               fontFamily: 'Montserrat',
              //               fontSize: 16,
              //               fontWeight: FontWeight.w500,
              //               color: Colors.grey,
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ],
              
              const SizedBox(height: 20),

              // Stimulation Control Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(18, 0, 0, 0),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Stimulation',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Slider and Controls
                    Row(
                      children: [
                        // Minus button
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRunning
                                  ? Color(0xFF333333).withOpacity(0.4)
                                  : Color(0XFF333333),
                          ),
                          child: IconButton(
                            onPressed: _isRunning ? null : () {
                              setState(() {
                                if (stimulationValue > 0) {
                                  stimulationValue--;
                                }
                              });
                            },
                            icon: const Icon(Icons.remove,
                                size: 28, color: Colors.white),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Progress indicator bars
                        Expanded(
                          child: Container(
                            height: 40,
                            child: Row(
                              children: List.generate(20, (index) {
                                final isActive = index < stimulationValue;
                                return Expanded(
                                  child: Container(
                                    width: 0.4,
                                    height: 40,
                                    margin:
                                        const EdgeInsets.symmetric(horizontal: 3),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? _isRunning ? Color(0xFF333333).withOpacity(0.4) : Color(0XFF333333)
                                          : const Color(0xFFE0E0E0),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Plus button
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRunning
                                  ? Color(0xFF333333).withOpacity(0.4)
                                  : Color(0XFF333333),
                          ),
                          child: IconButton(
                            onPressed: _isRunning ? null : () {
                              setState(() {
                                if (stimulationValue < 20) {
                                  stimulationValue++;
                                }
                              });
                            },
                            icon: const Icon(Icons.add,
                                size: 28, color: Colors.white),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Trigger button and count
                    Row(
                      children: [
                        const SizedBox(
                            width: 58), // Add space to move trigger button right
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isRunning
                                  ? Color(0xFF333333).withOpacity(0.4)
                                  : Color(0XFF333333),
                            //: const Color(0xFF333333).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextButton(
                            onPressed: _isRunning ? null : () async {
                            print("trigger button pressed");
                            flashBolt(1);
                            final ok = await TriggerStimulation(stimulationValue, 1);
                            if (!mounted) return;
                            if (!ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to Trigger')),
                              );
                            }
                          },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                            ),
                            child: const Text(
                              'Trigger',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const SizedBox(width: 0),
                            Text(
                              '${stimulationValue.toInt()}/20',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF000000),
                              ),
                            ),
                            SizedBox(
                              width: 60,
                              height: 30,
                              child: _showBolt
                                  ? const Icon(Icons.flash_on, size: 30, color: Color(0xFF000000))
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Live Angle and Trigger Angle Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(18, 0, 0, 0),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Live Angle',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(rollDeg - _calibrationOffset).toStringAsFixed(0)}°',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _isRunning
                                  ? Color(0xFF333333).withOpacity(0.4)
                                  : Color(0XFF333333),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextButton(
                              onPressed: _isRunning ? null : () {
                                  setState(() => _calibrationOffset = rollDeg);
                                  triggerAngleDeg = 0;
                                  print('calib set to $_calibrationOffset');
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                              child: const Text(
                                'Calibrate',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(18, 0, 0, 0),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Trigger Angle',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${triggerAngleDeg.toStringAsFixed(0)}°',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            height: 40,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isRunning
                                  ? Color(0xFF333333).withOpacity(0.4)
                                  : Color(0XFF333333),
                              borderRadius: BorderRadius.circular(20),
                            ),
                             child: TextButton(
                              onPressed: _isRunning ? null : () {
                                  setState(() {
                                    triggerAngleDeg = (rollDeg - _calibrationOffset);
                                });
                              print('set angle button pressed');
                            },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                            child: const Text(
                              'Set Angle',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                           ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Program and Steps Cards
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 100,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(18, 0, 0, 0),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          const Text(
                            'Program',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Controls and Timer Row
                          Expanded(
                            child: Row(
                              children: [
                                // Play Button
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _isRunning
                                          ? Color(0xFF333333).withOpacity(0.4)
                                          : Color(0XFF333333),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                      onPressed: _isRunning ? null : () {
                                        setState(() { 
                                          _isRunning = true;
                                          _seconds = 0;
                                          _steps = 0;
                                        });
                                        print('Start pressed');
                                        _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                                          if (!mounted) return;
                                          setState(() {
                                            _seconds++;
                                          });
                                        });
                                    },
                                    icon: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Stop Button
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _isRunning
                                          ? Color.fromARGB(255, 208, 49, 49)
                                          : Color.fromARGB(255, 208, 49, 49).withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    onPressed: _isRunning ? () {
                                      setState((){
                                         _isRunning = false;
                                         //_seconds = 0;
                                      });
                                      _clockTimer?.cancel();
                                      print('Stop pressed');
                                    } : null,
                                    icon: const Icon(
                                      Icons.stop,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Timer
                                Expanded(
                                  child: Text(
                                    _formatTime(_seconds),
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Steps Card
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 100,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(18, 0, 0, 0),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Title
                          const Text(
                            'Steps',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Steps Icon and Count
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.directions_walk,
                                  size: 24,
                                  color: Color(0xFF000000),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$_steps',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Advanced Settings Section
              Container(
                width: double.infinity,
                height: 230,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(18, 0, 0, 0),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Advanced Settings',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Set Trigger Angle Manually
                    Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text(
                            'Set Trigger Angle Manually',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: const TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '0.0',
                                hintStyle: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Color(0xFF000000),
                                  fontSize: 13,
                                ),
                              ),
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Color(0xFF000000),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Set Stimulation Duration
                    Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text(
                            'Set Stimulation Duration',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: selectedDuration,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down, color: Color.fromARGB(255, 50, 50, 50)),
                                items: durationOptions.map((int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(
                                      value.toString(),
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 13,
                                        color: Color(0xFF000000),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (int? newValue) {
                                  setState(() {
                                    selectedDuration = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Set Pulse Width
                    Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text(
                            'Set Pulse Width',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: selectedPulseWidth,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down, color: Color.fromARGB(255, 50, 50, 50)),
                                items: pulseWidthOptions.map((int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(
                                      value.toString(),
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 13,
                                        color: Color(0xFF000000),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (int? newValue) {
                                  setState(() {
                                    selectedPulseWidth = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Add Update Button
                    Center(
                      child: Container(
                         width: 100,
                         height: 40,
                        // padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0.5),
                        decoration: BoxDecoration(
                          color: _isRunning
                                  ? Color(0xFF333333).withOpacity(0.4)
                                  : Color(0XFF333333),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextButton(
                          onPressed: _isRunning ? null : () async {
                            print("update button pressed");
                            _stimDuration = selectedDuration;
                            final ok = await SendPulseWidth(selectedPulseWidth);
                            if (!mounted) return;
                            if (!ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Stimulation Duration updated. Failed to update pulse width')),
                              );
                            }
                            else{
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Stimulation Duration and Pulse Width updated')),
                              );
                            }
                            //final ok = await TriggerStimulation(stimulationValue, _stimDuration)
                          },
                          // onPressed: () {
                          //   print('Update button pressed');
                          //   _stimDuration = selectedDuration;
                          //   print(_stimDuration);

                          // },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                          ),
                          child: const Text(
                            'Update',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                  ],
                ),
              ),
               const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}