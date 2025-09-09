import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ShoulderAbductionScreen extends StatefulWidget {
  const ShoulderAbductionScreen({super.key});

  @override
  State<ShoulderAbductionScreen> createState() => _ShoulderAbductionScreenState();
}

class _ShoulderAbductionScreenState extends State<ShoulderAbductionScreen>
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
                    // Increased heights for tablet
                    cardHeight = isLandscape ? 600 : 680;
                  } else {
                    double screenHeight = MediaQuery.of(context).size.height;
                    cardHeight = (screenHeight * 0.98).clamp(200.0, 300.0);
                  }

                  // In landscape, further limit height to avoid overflow
                  if (isLandscape) {
                    double availableHeight = MediaQuery.of(context).size.height * 0.5;
                    if (cardHeight > availableHeight) {
                      cardHeight = availableHeight;
                    }
                  }

                  // Make image fill the card exactly
                  double imageWidth = cardWidth;

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
                      child: Container(
                        padding: const EdgeInsets.only(left: 0, top: 10, right: 0, bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            // Background image fills the card, moved further to the left
                            Positioned(
                              left: -100, // Move image 40 pixels to the left
                              top: 5,
                              bottom: 5,
                              child: Image.asset(
                                'assets/images/home_tab/biofeedback/Background[1].png',
                                height: cardHeight,
                                width: cardWidth,
                                // fit: BoxFit.cover,
                              ),
                            ),
                            // Rotatable overlay image with anchor point moved a little down
                            // Align(
                            //   alignment: Alignment.center,
                            //   child: ValueListenableBuilder<double>(
                            //     valueListenable: overlayAngleRad,
                            //     builder: (context, angle, child) {
                            //       // Increase insets to further reduce image size
                            //       const double sideInset = 90.0; // Increased from 62.0
                            //       const double topInset = 80.0;  // Increased from 54.0
                            //       const double bottomInset = 80.0; // Increased from 54.0
                            
                            //       // Calculate available space for the overlay (smaller)
                            //       final double innerW = imageWidth - (2 * sideInset);
                            //       final double innerH = cardHeight - topInset - bottomInset;
                            
                            //       // Move the anchor point a little down (e.g., 10% from the top)
                            //       const double anchorYOffset = 0.10; // 10% down from the top
                            
                            //       // Further reduce the height and width of the image
                            //       const double heightReductionFactor = 0.75; // Reduced from 0.90
                            //       const double widthReductionFactor = 0.75;  // New: reduce width as well
                            
                            //       // Offset values to move the image a little down and left
                            //       const double offsetX = 0.0;// Move -44xels to the left
                            //       const double offsetY = 0.0;  // Move 48 xels down
                            
                            //       return SizedBox(
                            //         width: innerW,
                            //         height: innerH,
                            //         child: FittedBox(
                            //           fit: BoxFit.contain,
                            //           alignment: Alignment.center,
                            //           child: RepaintBoundary(
                            //             child: Transform.translate(
                            //               offset: const Offset(offsetX, offsetY),
                            //               child: Transform.rotate(
                            //                 alignment: Alignment.topLeft,
                            //                 angle: angle,
                            //                 child: Image.asset(
                            //                   'assets/images/home_tab/biofeedback/arm[1].png',
                            //                   height: innerH * heightReductionFactor,
                            //                   width: innerW * widthReductionFactor,
                            //                   filterQuality: FilterQuality.high,
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //         ),
                            //       );
                            //     },
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Live Angle and Trigger Angle displayed directly (no cards)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Angle : ',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF000000),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${angleValue.toStringAsFixed(1)}°',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize:26,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF000000),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                           'Timer : ',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '00:15',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height:14),
              // Score display centered vertically and horizontally
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Score : ',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '30/50',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize:54,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
              // stop 
              const SizedBox(height: 14),
              Center(
                child: Container(
                  width: 100,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextButton(
                    onPressed: () {
                      print('stop program button pressed');
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Stop',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.not_interested,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
