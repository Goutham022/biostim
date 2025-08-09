import 'package:flutter/material.dart';
import '../controllers/wifi_pairing_controller.dart';

class ConnectingScreen extends StatelessWidget {
  final WifiPairingController controller;
  
  const ConnectingScreen({super.key, required this.controller});

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
          // Connection visualization with GIF in center
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 80 : 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Phone image (left side)
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
                
                // Loading GIF (center)
                Expanded(
                  child: Container(
                    height: isLargeTablet ? 80 : (isTablet ? 70 : 60),
                    child: Center(
                      child: Container(
                        width: isLargeTablet ? 60 : (isTablet ? 50 : 40),
                        height: isLargeTablet ? 60 : (isTablet ? 50 : 40),
                        child: Image.asset(
                          'assets/gifs/loading.gif',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: isLargeTablet ? 60 : (isTablet ? 50 : 40),
                              height: isLargeTablet ? 60 : (isTablet ? 50 : 40),
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Device icon (right side)
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
          
          SizedBox(height: isTablet ? 80 : 60),
          
          // Text
          Text(
            'Trying to Connect. Please Wait',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isLargeTablet ? 24 : (isTablet ? 20 : 18),
              color: const Color(0xFF424242),
            ),
          ),
        ],
      ),
    );
  }
} 