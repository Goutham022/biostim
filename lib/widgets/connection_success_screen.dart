import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wifi_pairing_controller.dart';
import '../screens/connected_screen.dart';
import 'dart:async';

class ConnectionSuccessScreen extends StatefulWidget {
  final WifiPairingController controller;
  
  const ConnectionSuccessScreen({super.key, required this.controller});

  @override
  State<ConnectionSuccessScreen> createState() => _ConnectionSuccessScreenState();
}

class _ConnectionSuccessScreenState extends State<ConnectionSuccessScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    // Start timer to navigate after 5 seconds
    _navigationTimer = Timer(const Duration(seconds: 5), () {
      Get.off(() => const ConnectedScreen());
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargeTablet = screenSize.width > 900;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Spacing between status bar and title
          SizedBox(height: 75),
          
          // Title
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 20, bottom: 50),
              child: Text(
                'Connected Successfully',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF424242),
                ),
              ),
            ),
          ),

          // Spacing between title and animation
          SizedBox(height: isTablet ? 60 : 50),
          
          // Connection visualization with success - matching connecting_screen container size
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 40),
            child: Container(
              width: isLargeTablet ? 420 : (isTablet ? 380 : 240),
              height: isLargeTablet ? 420 : (isTablet ? 380 : 240),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Phone image (left side) - matching connecting_screen size
                  Container(
                    width: isLargeTablet ? 120 : (isTablet ? 100 : 80),
                    height: isLargeTablet ? 120 : (isTablet ? 100 : 80),
                    child: Image.asset(
                      'assets/onboarding/image.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: isLargeTablet ? 120 : (isTablet ? 100 : 80),
                          height: isLargeTablet ? 120 : (isTablet ? 100 : 80),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            Icons.phone_android,
                            size: isLargeTablet ? 60 : (isTablet ? 50 : 40),
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Success animation (center) - matching connecting_screen gif size
                  Expanded(
                    child: Container(
                      height: isLargeTablet ? 120 : (isTablet ? 100 : 80),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Green connection lines
                          CustomPaint(
                            size: Size(double.infinity, isLargeTablet ? 120 : (isTablet ? 100 : 80)),
                            painter: ConnectionLinesPainter(),
                          ),
                          
                          // Success GIF - matching connecting_screen size
                          Container(
                            width: isLargeTablet ? 100 : (isTablet ? 80 : 60),
                            height: isLargeTablet ? 100 : (isTablet ? 80 : 60),
                            child: Image.asset(
                              'assets/gifs/correct.gif',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: isLargeTablet ? 100 : (isTablet ? 80 : 60),
                                  height: isLargeTablet ? 100 : (isTablet ? 80 : 60),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: isLargeTablet ? 50 : (isTablet ? 40 : 30),
                                    color: Colors.green[600],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Device icon (right side) - matching connecting_screen size
                  Container(
                    width: isLargeTablet ? 120 : (isTablet ? 100 : 80),
                    height: isLargeTablet ? 120 : (isTablet ? 100 : 80),
                    child: Image.asset(
                      'assets/onboarding/device_icon_small.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: isLargeTablet ? 120 : (isTablet ? 100 : 80),
                          height: isLargeTablet ? 120 : (isTablet ? 100 : 80),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            Icons.devices,
                            size: isLargeTablet ? 60 : (isTablet ? 50 : 40),
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Spacing between animation and subtitle
          SizedBox(height: isTablet ? 120 : 100),
          
          // Subtitle below the animation - matching connecting_screen styling
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 40),
            child: Text(
              'Device Connected Successfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),

          // Spacer to push everything up
          Spacer(),
        ],
      ),
    );
  }
}

// Custom painter for connection lines
class ConnectionLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF79D976)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final centerY = size.height / 2;
    
    // Draw horizontal line from left to center
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width * 0.4, centerY),
      paint,
    );
    
    // Draw horizontal line from center to right
    canvas.drawLine(
      Offset(size.width * 0.6, centerY),
      Offset(size.width, centerY),
      paint,
    );
  }

  @override
  bool shouldRepaint(ConnectionLinesPainter oldDelegate) => false;
} 