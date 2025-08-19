import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'dart:math' as math;

/////////////////////////////////////////////////////////////////////////////////////////////////////////start -nithin
class ImuAngles {
  /// Common aerospace convention:
  ///   rollX = atan2(ay, az)
  ///   pitchY = atan2(-ax, sqrt(ay^2 + az^2))
  final double rollXDeg;
  final double pitchYDeg;
  final double rollYDeg; // <-- new, for roll around Y

  const ImuAngles({
    required this.rollXDeg,
    required this.pitchYDeg,
    required this.rollYDeg, // <-- new
  });
}


ImuAngles computeAnglesFromAccel({
  required num ax,
  required num ay,
  required num az,
  bool addPitch90Offset = false,
}) {
  final double x = ax.toDouble();
  final double y = ay.toDouble();
  final double z = az.toDouble();

  const double eps = 1e-9;

  // Roll around X (usual)
  final double rollXRad = -math.atan2(
    y,
    (z.abs() < eps ? (z >= 0 ? eps : -eps) : z),
  );

  // Pitch around Y (usual)
  final double pitchYRad = math.atan2(
    -x,
    math.sqrt(y * y + z * z + eps),
  );

  // Roll around Y (optional)
  final double rollYRad = math.atan2(
    x,
    (z.abs() < eps ? (z >= 0 ? eps : -eps) : z),
  );

  // Convert to degrees
  final double rollXDeg = rollXRad * 180.0 / math.pi;
  final double pitchYDeg = pitchYRad * 180.0 / math.pi;
  final double rollYDeg = rollYRad * 180.0 / math.pi;

  return ImuAngles(
    rollXDeg:  rollXDeg + 90 ,   // <<-- added offset here
    pitchYDeg: pitchYDeg,
    rollYDeg:  rollYDeg,
  );
}


/////////////////////////////////////////////////////////////////////////////////////////////////End -nithin
class FootDropRehabPage extends StatefulWidget {
  const FootDropRehabPage({super.key});
  
  @override
  State<FootDropRehabPage> createState() => _FootDropRehabPageState();
}
  
class _FootDropRehabPageState extends State<FootDropRehabPage> with SingleTickerProviderStateMixin{//Made changes to use SingleTickerProviderStateMixin for AnimationController
  double stimulationValue = 10.0;
  double angleValue = -12.5;
  double triggerAngleValue = 15.0;
  bool isPlaying = false;
  String selectedDuration = '1';
  String selectedPulseWidth = '100';
  
  final List<String> durationOptions = ['1', '2', '3', '4', '5', '6', '7', '8','9', '10'];
  final List<String> pulseWidthOptions = ['100', '200', '300', '400', '500'];
  final List<int> strengthOptions = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  late final AnimationController _lottieController;//nithin
  double _sliderValue = 0.0;     // 0..1 for Lottie frames//nithin
  double currentAngle = 0.0;     // from ESP (deg)//nithin 
  late http.Client _client;// for HTTP connection//nithin
  StreamSubscription<String>? _streamSub;// continous http data stream from ESP32//nithin
  Timer? _angleTimer; // Timer for periodic angle fetching//nithin
  Timer? _pollTimer;
  Timer? _fesTimer;
  bool _firing = false;          // true while a stimulation window is active
  Timer? _stopTimer; 
  bool _inFlight = false;           // prevent overlapping requests
  Duration _interval = const Duration(milliseconds: 120);

  int? accelXRaw, accelYRaw, accelZRaw;// Raw accelerometer values from ESP32//nithin
  double pitchY_deg = 0.0;
  // double rollX_deg = 0.0; // Roll around X-axis (deg) //nithin
  double rollY_deg = 0.0; // Roll around Y-axis (deg)
  Duration httpTimeout   = const Duration(milliseconds: 800);
  double _calibrationOffset = 0.0;
  double current_value = 0;
  double? _prevValue;
  int selectedStrength = 3;  
  ////////////////////////////////////////////////////////////////////////////////////////////////////////start -nithin
  // Function to send trigger data to the server

  void startAccelPolling() {
  _pollTimer?.cancel();
  _pollTimer = Timer.periodic(_interval, (_) => _fetchAngleFromESP());
}

// Optional: call to stop (e.g., in pause or dispose)
void stopAccelPolling() {
  _pollTimer?.cancel();
  _pollTimer = null;
}

  @override
  void initState() {
    super.initState();
    startAccelPolling();
    _lottieController = AnimationController(vsync: this);
  _client = http.Client();
  // _fetchAngleFromESP();
    // Optional: start polling when widget mounts
    _startAngleSimulation();
  }

   Future<void> _sendStim(bool fire) async {
  try {
    final uri = Uri.parse('http://192.168.4.1/fire');
    final body = jsonEncode({
      "strength":strengthOptions[selectedStrength] ,
      "fire": fire,
    });
    await _client
        .post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: body,
        )
        .timeout(const Duration(milliseconds: 800));
    // print('Sent fire=$fire strength=$selectedStrength');
  } catch (_) {
    // swallow/log if needed
  }
}

  @override
  void dispose() {
    _lottieController.dispose();
    _angleTimer?.cancel();
    stopAccelPolling();
    super.dispose();
  }

    void _startAngleSimulation() {
    _angleTimer?.cancel();
    _angleTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      _fetchAngleFromESP();
    });
  }

  
Future<void> sendTrigger({required int strength}) async {
  try {
    final res = await http
        .post(
          Uri.parse('http://192.168.4.1/Trigger'),
          headers: const {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'Strength': strength,
          }),
        )
        .timeout(const Duration(seconds: 1));

    if (res.statusCode == 200) {
      print('Trigger OK: ${res.body}');
    } else {
      print('Trigger failed: ${res.statusCode} ${res.body}');
    }
  } catch (e) {
    print('Trigger error: $e');
  }
}



 Future<void> _fetchAngleFromESP() async {
  if (_inFlight) return;              // skip if last call still running
  _inFlight = true;
      try {
      final res = await _client
          .get(
            Uri.parse('http://192.168.4.1/RawAccel'),
            headers: const {
              'Connection': 'keep-alive',
            },
          )
          .timeout(httpTimeout);

      if (res.statusCode == 200) {
        final obj = jsonDecode(res.body);

        // Read as int directly
        final int? axRaw = (obj['accel_x'] as num?)?.toInt();
        final int? ayRaw = (obj['accel_y'] as num?)?.toInt();
        final int? azRaw = (obj['accel_z'] as num?)?.toInt();

        // print("Raw Accel: ax=$axRaw, ay=$ayRaw, az=$azRaw");

        if (axRaw != null && ayRaw != null && azRaw != null) {
          accelXRaw = axRaw;
          accelYRaw = ayRaw;
          accelZRaw = azRaw;

          // Convert to double for angle calculation
          final angles = computeAnglesFromAccel(
            ax: accelXRaw!.toDouble(),
            ay: accelYRaw!.toDouble(),
            az: accelZRaw!.toDouble(),
            addPitch90Offset: true, // true to match ESP's +90 offset
          );

          final double rollX_deg = angles.rollXDeg;
            pitchY_deg = angles.pitchYDeg;
            rollY_deg = angles.rollYDeg; // <-- new, for roll around Y

          // Print rolls
          // print('Roll (X-axis): ${rollX_deg.toStringAsFixed(2)}°');
          print('Pitch (Y-axis): ${rollX_deg.toStringAsFixed(2)}°');
              setState(() {
       currentAngle = rollX_deg; // or pitchDeg
      _sliderValue = _mapAngleToLottieValue(currentAngle - _calibrationOffset);
      _lottieController.value = _sliderValue;

      // If you also want to display raw values:
      // accelXValue = ax; accelYValue = ay; accelZValue = az;
    });
          
        }
      }
    }

   catch (_) {
    // swallow or add backoff if needed
  } finally {
    _inFlight = false;
  }
}

  // Map your mechanical angle to Lottie progress [0..1]
  // Adjust min/max to your use-case (e.g., -90..+90, 0..180, etc.)
  double _mapAngleToLottieValue(double angleDeg) {
    const double minDeg = -90;     // change if needed
    const double maxDeg = 160;   // change if needed
    final norm = ((angleDeg - minDeg) / (maxDeg - minDeg)).clamp(0.0, 1.0);
    return norm;
  }



Future<void> sendPulseWidth({required int pulseWidth,required int Offtime}) async {
  try {
    final res = await http
        .post(
          Uri.parse('http://192.168.4.1/pulseWidth'),
          headers: const {'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'PulseWidth': pulseWidth,
            'Offtime': Offtime, // Assuming you want to set Offtime to 10
          }),
        )
        .timeout(const Duration(seconds: 1));

    if (res.statusCode == 200) {
      print('Pulse Width OK: ${res.body}');
    } else {
      print('Pulse Width failed: ${res.statusCode} ${res.body}'); 
    }
  } catch (e) {
    print('Pulse Width error: $e');
  }
}
           
void startFesTask() {
  _fesTimer?.cancel();

  _fesTimer = Timer.periodic(const Duration(milliseconds: 200), (_) async {
    if (isPlaying) {
      final current_value = currentAngle - _calibrationOffset;

      // Rising edge: prev < trigger && curr >= trigger
      if (!_firing &&
          _prevValue != null &&
          _prevValue! < triggerAngleValue &&
          current_value >= triggerAngleValue) {

        _firing = true;
        _stopTimer?.cancel();          // clear any pending stop
        await _sendStim(true);         // START stimulation

        final secs = 1; // change the duration as needed
        _stopTimer = Timer(Duration(seconds: secs), () async {
          await _sendStim(false);      // STOP after duration
          _firing = false;
        });
      }

      _prevValue = current_value;
    } else {
      // If user paused, ensure we stop stimulation and clear timers
      _stopTimer?.cancel();
      if (_firing) {
        await _sendStim(false);
        _firing = false;
      }
      _fesTimer?.cancel();
    }
  });
}

void stopFesTask() {
  _fesTimer?.cancel();
  _fesTimer = null;
  _stopTimer?.cancel();
  _stopTimer = null;
  if (_firing) {
    _sendStim(false);  // best-effort stop
    _firing = false;
  }
}

  ////////////////////////////////////////////////////////////////////////// //////////////////////////////////End -nithin

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
              Container(
                width: double.infinity,
                height: 180,
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Base layer - Background image
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/home_tab/footdrop/Background_croped.png'),//Background image to Background_//nithin
                            fit: BoxFit.contain,//Adjust to contain//nithin
                          ),
                        ),
                      ),
//////////////////////////////////////////////////////////////////////////////////////////////////////start -nithin
///Added the WalkingLeg.json animation
                      Center(
                        child: SizedBox(
                            width: 200, // set desired width
                            height: 200, // set desired height
                      child: Lottie.asset(
                        'assets/images/home_tab/footdrop/WalkingLeg.json',
                        controller: _lottieController,
                        fit: BoxFit.contain,      // keeps aspect ratio inside the card
                        alignment: Alignment.center,
                        onLoaded: (composition) {
                          _lottieController.duration = composition.duration;
                          _lottieController.value = _sliderValue;
                        },
                      ),
                        ),
                    ),
//////////////////////////////////////////////////////////////////////////////////////////////////////End -nithin
                      
                      // Positioned(
                      //   top: 0,
                      //   left: 0,
                      //   right: 0,
                      //   bottom: 0,
                      //   child: Container(
                      //     decoration: const BoxDecoration(
                      //       image: DecorationImage(
                      //         image: AssetImage('assets/images/home_tab/footdrop/Background_croped.png'),
                      //         fit: BoxFit.contain,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              
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
                        fontSize: 14,
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
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                if (stimulationValue > 0) {
                                  stimulationValue--;
                                }
                              });
                            },
                            icon: const Icon(Icons.remove, size: 24, color: Colors.black),
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
                                    width: 0.5,
                                    height: 40,
                                    margin: EdgeInsets.symmetric(horizontal: 2),
                                    decoration: BoxDecoration(
                                      color: isActive ? Colors.black : const Color(0xFFE0E0E0),
                                      borderRadius: BorderRadius.circular(1),
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
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                if (stimulationValue < 20) {
                                  stimulationValue++;
                                }
                              });
                            },
                            icon: const Icon(Icons.add, size: 24, color: Colors.black),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Trigger button and count
                    Row(
                      children: [
                        const SizedBox(width: 58), // Add space to move trigger button right
                        Container(
                          // width: 100,
                          height: 32,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF333333),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextButton(
                            onPressed: () {
                            print('trigger button pressed');
                            sendTrigger(strength: 5);///Send strength and enable status to the server//nithin
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
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const SizedBox(width: 0 ),
                            Text(
                              '${stimulationValue.toInt()}/20',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF000000),
                              ),
                            ),
                            const SizedBox(width: 38),
                            const Icon(Icons.flash_on, size: 20, color: Colors.black),
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
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(currentAngle - _calibrationOffset).toStringAsFixed(1)}°',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            height: 32,

                            //padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF333333),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextButton(
                            onPressed: () {
                                setState(() {
                                       _calibrationOffset = currentAngle; // whatever current is → new zero
                                 });
                            print('cali button pressed');
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
                              fontSize: 12,
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
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${triggerAngleValue.toStringAsFixed(1)}°',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF333333),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Set Angle',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
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
                  // Program Card
                  Container(
                    width: 200,
                    height: 100,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        
                        const SizedBox(height: 6),
                        
                        // Controls and Timer Row
                        Expanded(
                          child: Row(
                            children: [
                              // Play Button
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF333333),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isPlaying = !isPlaying; // toggle
                                      
                                    });
                                      if (isPlaying) {
                                        startFesTask();
                                     }
                                  },
                                  icon: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              
                              const SizedBox(width: 13),
                              
                              // Stop Button
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF333333),
                                  shape: BoxShape.circle,
                                ),
                              
                                
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isPlaying = false;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.stop,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              const SizedBox(width: 25),
                              
                              // Timer
                              const Text(
                                '00:15',
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
                  
                  const SizedBox(width: 12),
                  
                  // Steps Card
                  Container(
                    width: 108,
                    height: 100,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                          'Steps',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF000000),
                          ),
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // Steps Icon and Count
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.directions_walk,
                                size: 30,
                                color: Color(0xFF000000),
                              ),
                              
                              const SizedBox(width: 8),
                              
                              const Text(
                                '35',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 24,
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
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Advanced Settings Section
              Container(
                width: double.infinity,
                height: 215,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
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
                              fontSize: 13,
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
                                  color: Color(0xFF555555),
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
                              fontSize: 13,
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
                              child: DropdownButton<String>(
                                value: selectedDuration,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down, color: Color.fromARGB(255, 50, 50, 50)),
                                items: durationOptions.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 13,
                                        color: Color(0xFF000000),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
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
                              fontSize: 13,
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
                              child: DropdownButton<String>(
                                value: selectedPulseWidth,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down, color: Color.fromARGB(255, 50, 50, 50)),
                                items: pulseWidthOptions.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 13,
                                        color: Color(0xFF000000),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
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
                         height: 32,
                        // padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF333333),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextButton(
                          onPressed: () {
                            print('Update button pressed');
                            sendPulseWidth(pulseWidth: 10,Offtime: 10);//Change pulse width to 10//nithin
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                          ),
                          child: const Text(
                            'Update',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
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