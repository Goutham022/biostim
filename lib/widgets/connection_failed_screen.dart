import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_settings/app_settings.dart';
import '../controllers/wifi_pairing_controller.dart';
import '../screens/not_connected_screen.dart';

class ConnectionFailedScreen extends StatelessWidget {
  final WifiPairingController controller;
  
  const ConnectionFailedScreen({super.key, required this.controller});

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
          // Connection visualization with failure
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
                    'assets/onboarding/image.png',
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
                
                // Failed animation
                Expanded(
                  child: Container(
                    height: isLargeTablet ? 80 : (isTablet ? 70 : 60),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Red connection lines
                        CustomPaint(
                          size: Size(double.infinity, isLargeTablet ? 80 : (isTablet ? 70 : 60)),
                          painter: FailedConnectionLinesPainter(),
                        ),
                        
                        // Failed GIF
                        Container(
                          width: isLargeTablet ? 60 : (isTablet ? 50 : 40),
                          height: isLargeTablet ? 60 : (isTablet ? 50 : 40),
                          child: Image.asset(
                            'assets/onboarding/failed.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: isLargeTablet ? 60 : (isTablet ? 50 : 40),
                                height: isLargeTablet ? 60 : (isTablet ? 50 : 40),
                                decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: isLargeTablet ? 30 : (isTablet ? 25 : 20),
                                  color: Colors.red[600],
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
                    'assets/onboarding/device_icon_small.png',
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
          
          SizedBox(height: isTablet ? 60 : 40),
          
          // Title
          Text(
            'Connection Failed!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isLargeTablet ? 28 : (isTablet ? 24 : 20),
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
          ),
          
          SizedBox(height: isTablet ? 40 : 30),
          
          // Instructions
          Container(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInstructionItem(
                  context,
                  '1. Check WiFi again. Retry connecting after turning WiFi ON.',
                  isTablet,
                  isLargeTablet,
                ),
                SizedBox(height: isTablet ? 20 : 15),
                _buildInstructionItem(
                  context,
                  '2. Put the device into pairing mode again.',
                  isTablet,
                  isLargeTablet,
                ),
                SizedBox(height: isTablet ? 20 : 15),
                _buildInstructionItem(
                  context,
                  '3. Retry manually in WiFi settings.\n   SSID - Biostep+\n   Password - biostim@123',
                  isTablet,
                  isLargeTablet,
                ),
              ],
            ),
          ),
          
          SizedBox(height: isTablet ? 60 : 40),
          
          // Buttons
          Column(
            children: [
              // Retry Manually button
              Container(
                width: double.infinity,
                height: isLargeTablet ? 60 : (isTablet ? 55 : 50),
                child: ElevatedButton(
                  onPressed: () {
                    AppSettings.openAppSettings(type: AppSettingsType.wifi);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isLargeTablet ? 30 : (isTablet ? 27 : 25)),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Retry Manually',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: isLargeTablet ? 18 : (isTablet ? 17 : 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: isTablet ? 20 : 15),
              
              // Retry button
              Container(
                width: double.infinity,
                height: isLargeTablet ? 60 : (isTablet ? 55 : 50),
                child: ElevatedButton(
                  onPressed: () {
                    controller.retryConnection();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF424242),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isLargeTablet ? 30 : (isTablet ? 27 : 25)),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: isLargeTablet ? 18 : (isTablet ? 17 : 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: isTablet ? 20 : 15),
              
              // Skip button
              Container(
                width: double.infinity,
                height: isLargeTablet ? 60 : (isTablet ? 55 : 50),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const NotConnectedScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.grey[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isLargeTablet ? 30 : (isTablet ? 27 : 25)),
                    ),
                    elevation: 1,
                  ),
                  child: Text(
                    'Skip',
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
        ],
      ),
    );
  }
  
  Widget _buildInstructionItem(
    BuildContext context,
    String text,
    bool isTablet,
    bool isLargeTablet,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: isTablet ? 8 : 6),
          width: isLargeTablet ? 8 : (isTablet ? 6 : 4),
          height: isLargeTablet ? 8 : (isTablet ? 6 : 4),
          decoration: BoxDecoration(
            color: Colors.grey[600],
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: isTablet ? 15 : 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isLargeTablet ? 18 : (isTablet ? 16 : 14),
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter for failed connection lines
class FailedConnectionLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red[400]!
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
  bool shouldRepaint(FailedConnectionLinesPainter oldDelegate) => false;
} 