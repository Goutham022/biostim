import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ShoulderAbductionPage extends StatefulWidget {
  const ShoulderAbductionPage({super.key});

  @override
  State<ShoulderAbductionPage> createState() => _ShoulderAbductionPageState();
}

class _ShoulderAbductionPageState extends State<ShoulderAbductionPage>
    with TickerProviderStateMixin {
  double stimulationValue = 10.0;
  double angleValue = -12.5;
  double triggerAngleValue = 15.0;
  bool isPlaying = false;
  String selectedDuration = '1';
  String selectedPulseWidth = '100';

  // Overlay rotation state
  final ValueNotifier<double> overlayAngleRad = ValueNotifier(0.0);
  AnimationController? _animationController;
  Animation<double>? _rotationAnimation;

  final List<String> durationOptions = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10'
  ];
  final List<String> pulseWidthOptions = ['100', '200', '300', '400', '500'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Helper methods for overlay rotation
  void setOverlayAngleDegrees(double deg) {
    overlayAngleRad.value = deg * (3.14159 / 180.0); // Convert degrees to radians
  }

  void setOverlayAngleRadians(double rad) {
    overlayAngleRad.value = rad;
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
                'Shoulder Abduction',
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
                            'Angle',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${angleValue.toStringAsFixed(1)}°',
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
                            decoration: BoxDecoration(
                              color: const Color(0xFF333333),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextButton(
                              onPressed: () {
                                print('cali button pressed');
                                setOverlayAngleDegrees(45);
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Center(
                            child: Text(
                              'Set Target Angle',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF000000),
                              ),
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
                            height: 32,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF333333),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextButton(
                              onPressed: () {
                                print('cali button pressed');
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
                ],
              ),
              const SizedBox(height: 24),

              // Steps Card
              Container(
                height: 100,
                width: 100,
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
                      'Timer',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Steps Icon and Count
                    Card(
                      color: Colors.grey[100],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedDuration == 'NA' ? null : selectedDuration,
                            hint: const Text('NA'),
                            items: [
                              const DropdownMenuItem(
                                value: 'NA',
                                child: Text('NA'),
                              ),
                              const DropdownMenuItem(
                                value: '1',
                                child: Text('1 Min'),
                              ),
                              const DropdownMenuItem(
                                value: '2',
                                child: Text('2 Min'),
                              ),
                              const DropdownMenuItem(
                                value: '3',
                                child: Text('3 Min'),
                              ),
                              const DropdownMenuItem(
                                value: '4',
                                child: Text('4 Min'),
                              ),
                              const DropdownMenuItem(
                                value: '5',
                                child: Text('5 Min'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedDuration = value ?? 'NA';
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.directions_walk,
                            size: 24,
                            color: Color(0xFF000000),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '69',
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
              // const SizedBox(height: 24),
              // const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}