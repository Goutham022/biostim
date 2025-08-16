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
          // Title - pixel-identical to device_not_found_screen
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 20, bottom: 50),
              child: Text(
                'Connection Failed',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF424242),
                ),
              ),
            ),
          ),
          // Add spacing before image - pixel-identical to device_not_found_screen
          SizedBox(height: isTablet ? 50 : 40),

          // Connection visualization with failure - using connection_success_screen metrics
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 40),
            child: Container(
              width: isLargeTablet ? 420 : (isTablet ? 380 : 240),
              height: isLargeTablet ? 420 : (isTablet ? 380 : 240),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Phone image (left side) - using connection_success_screen size
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
                  
                  // Failed animation (center) - using connection_success_screen gif size
                  Expanded(
                    child: Container(
                      height: isLargeTablet ? 120 : (isTablet ? 100 : 80),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Red connection lines
                          CustomPaint(
                            size: Size(double.infinity, isLargeTablet ? 120 : (isTablet ? 100 : 80)),
                            // painter: FailedConnectionLinesPainter(),
                          ),
                          
                          // Failed GIF - using connection_success_screen size
                          Container(
                            width: isLargeTablet ? 100 : (isTablet ? 80 : 60),
                            height: isLargeTablet ? 100 : (isTablet ? 80 : 60),
                            child: Image.asset(
                              'assets/onboarding/failed.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: isLargeTablet ? 100 : (isTablet ? 80 : 60),
                                  height: isLargeTablet ? 100 : (isTablet ? 80 : 60),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: isLargeTablet ? 50 : (isTablet ? 40 : 30),
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
                  
                  // Device icon (right side) - using connection_success_screen size
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
          SizedBox(height: isTablet ? 60 : 40),
          
          // Instructions - pixel-identical to device_not_found_screen
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
                 // Network details - pixel-identical to device_not_found_screen
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
          
          SizedBox(height: isTablet ? 100 : 80),
          
          // Buttons arranged horizontally - pixel-identical to device_not_found_screen
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
                       backgroundColor: const Color(0xFF424242),
                        foregroundColor: Colors.white, 
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
                          fontWeight: FontWeight.w400,
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
                          fontSize: isLargeTablet ? 12 : (isTablet ? 17 : 12),
                          fontWeight: FontWeight.w400,
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

// // Custom painter for failed connection lines
// class FailedConnectionLinesPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.red[400]!
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3.0;

//     final centerY = size.height / 2;
    
//     // Draw horizontal line from left to center
//     canvas.drawLine(
//       Offset(0, centerY),
//       Offset(size.width * 0.4, centerY),
//       paint,
//     );
    
//     // Draw horizontal line from center to right
//     canvas.drawLine(
//       Offset(size.width * 0.6, centerY),
//       Offset(size.width, centerY),
//       paint,
//     );
//   }

//   @override
//   bool shouldRepaint(FailedConnectionLinesPainter oldDelegate) => false;
// } 