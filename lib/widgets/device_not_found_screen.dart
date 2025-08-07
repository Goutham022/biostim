import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_settings/app_settings.dart';
import '../controllers/wifi_pairing_controller.dart';
import '../screens/not_connected_screen.dart';

class DeviceNotFoundScreen extends StatelessWidget {
  final WifiPairingController controller;
  
  const DeviceNotFoundScreen({super.key, required this.controller});

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
          // Title
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 20, bottom: 30),
              child: Text(
                'Device Not Found',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF424242),
                ),
              ),
            ),
          ),

          // Error image with concentric rings design
          Container(
            width: isLargeTablet ? 200 : (isTablet ? 180 : 150),
            height: isLargeTablet ? 200 : (isTablet ? 180 : 150),
            child: Image.asset(
              'assets/onboarding/search_failed.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: isLargeTablet ? 200 : (isTablet ? 180 : 150),
                  height: isLargeTablet ? 200 : (isTablet ? 180 : 150),
                  child: CustomPaint(
                    painter: SearchFailedIconPainter(),
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: isTablet ? 60 : 40),
          
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
                   '2. Put the device into pairing mode again. It times out after some time.',
                   isTablet,
                   isLargeTablet,
                 ),
                 SizedBox(height: isTablet ? 20 : 15),
                 _buildInstructionItem(
                   context,
                   '3. You can retry manually by going to WiFi settings and connecting to the following network.',
                   isTablet,
                   isLargeTablet,
                 ),
                 SizedBox(height: isTablet ? 15 : 10),
                 // Network details
                 Padding(
                   padding: EdgeInsets.only(left: isTablet ? 35 : 27),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         'SSID - Biostep+',
                         style: TextStyle(
                           fontFamily: 'Montserrat',
                           fontSize: isLargeTablet ? 16 : (isTablet ? 14 : 12),
                           color: Colors.grey[700],
                           height: 1.4,
                         ),
                       ),
                       SizedBox(height: 5),
                       Text(
                         'Password - biostim@123',
                         style: TextStyle(
                           fontFamily: 'Montserrat',
                           fontSize: isLargeTablet ? 16 : (isTablet ? 14 : 12),
                           color: Colors.grey[700],
                           height: 1.4,
                         ),
                       ),
                     ],
                   ),
                 ),
              ],
            ),
          ),
          
          SizedBox(height: isTablet ? 60 : 40),
          
          // Buttons arranged horizontally
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 10),
            child: Row(
              children: [
                // Skip button
                Expanded(
                  flex: 1,
                  child: Container(
                    height: isLargeTablet ? 40 : (isTablet ? 55 : 40),
                    margin: EdgeInsets.only(right: isTablet ? 8 : 5),
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
                          fontSize: isLargeTablet ? 12 : (isTablet ? 17 : 12),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Retry Manually button
                Expanded(
                  flex: 2,
                  child: Container(
                    height: isLargeTablet ? 40 : (isTablet ? 55 : 40),
                    margin: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 5),
                    child: ElevatedButton(
                      onPressed: () {
                        AppSettings.openAppSettings(type: AppSettingsType.wifi);
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
                        'Retry Manually',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: isLargeTablet ? 16 : (isTablet ? 17 : 12),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Retry button
                Expanded(
                  flex: 1,
                  child: Container(
                    height: isLargeTablet ? 40 : (isTablet ? 55 : 40),
                    margin: EdgeInsets.only(left: isTablet ? 8 : 5),
                    child: ElevatedButton(
                      onPressed: () {
                        controller.retryScanning();
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
                          fontSize: isLargeTablet ? 12 : (isTablet ? 17 : 12),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

// Custom painter for search failed icon with concentric rings
class SearchFailedIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    
    // Draw three concentric rings
    for (int i = 1; i <= 3; i++) {
      final radius = maxRadius * (i / 3);
      final paint = Paint()
        ..color = Colors.grey[400]!.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawCircle(center, radius, paint);
    }
    
    // Draw X mark in the center
    final xPaint = Paint()
      ..color = Colors.grey[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    final xSize = maxRadius * 0.3;
    canvas.drawLine(
      Offset(center.dx - xSize, center.dy - xSize),
      Offset(center.dx + xSize, center.dy + xSize),
      xPaint,
    );
    canvas.drawLine(
      Offset(center.dx + xSize, center.dy - xSize),
      Offset(center.dx - xSize, center.dy + xSize),
      xPaint,
    );
  }

  @override
  bool shouldRepaint(SearchFailedIconPainter oldDelegate) => false;
} 