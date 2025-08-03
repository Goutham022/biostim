import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wifi_pairing_controller.dart';

class ConnectionSuccessScreen extends StatelessWidget {
  final WifiPairingController controller;
  
  const ConnectionSuccessScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargeTablet = screenSize.width > 900;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Connection visualization with success
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 80 : 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Phone image
                Container(
                  width: isLargeTablet ? 80 : (isTablet ? 70 : 60),
                  height: isLargeTablet ? 80 : (isTablet ? 70 : 60),
                  child: Image.asset(
                    'assets/images/image.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: isLargeTablet ? 80 : (isTablet ? 70 : 60),
                        height: isLargeTablet ? 80 : (isTablet ? 70 : 60),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.phone_android,
                          size: isLargeTablet ? 40 : (isTablet ? 35 : 30),
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
                
                // Success animation
                Expanded(
                  child: Container(
                    height: isLargeTablet ? 80 : (isTablet ? 70 : 60),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Green connection lines
                        CustomPaint(
                          size: Size(double.infinity, isLargeTablet ? 80 : (isTablet ? 70 : 60)),
                          painter: ConnectionLinesPainter(),
                        ),
                        
                        // Success GIF
                        Container(
                          width: isLargeTablet ? 60 : (isTablet ? 50 : 40),
                          height: isLargeTablet ? 60 : (isTablet ? 50 : 40),
                          child: Image.asset(
                            'assets/gifs/correct.gif',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: isLargeTablet ? 60 : (isTablet ? 50 : 40),
                                height: isLargeTablet ? 60 : (isTablet ? 50 : 40),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: isLargeTablet ? 30 : (isTablet ? 25 : 20),
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
                
                // Device icon
                Container(
                  width: isLargeTablet ? 80 : (isTablet ? 70 : 60),
                  height: isLargeTablet ? 80 : (isTablet ? 70 : 60),
                  child: Image.asset(
                    'assets/images/device_icon_small.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: isLargeTablet ? 80 : (isTablet ? 70 : 60),
                        height: isLargeTablet ? 80 : (isTablet ? 70 : 60),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.devices,
                          size: isLargeTablet ? 40 : (isTablet ? 35 : 30),
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: isTablet ? 80 : 60),
          
          // Success text
          Text(
            'Connected Successfully',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isLargeTablet ? 28 : (isTablet ? 24 : 20),
              fontWeight: FontWeight.w600,
              color: Colors.green[700],
            ),
          ),
          
          SizedBox(height: isTablet ? 60 : 40),
          
          // Continue button
          Container(
            width: isLargeTablet ? 200 : (isTablet ? 180 : 150),
            height: isLargeTablet ? 60 : (isTablet ? 55 : 50),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to next screen or go back
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isLargeTablet ? 30 : (isTablet ? 27 : 25)),
                ),
                elevation: 2,
              ),
              child: Text(
                'Continue',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: isLargeTablet ? 18 : (isTablet ? 17 : 16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
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
      ..color = Colors.green[400]!
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