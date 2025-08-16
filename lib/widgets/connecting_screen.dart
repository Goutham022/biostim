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
                'Connecting...',
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
          
          // Connection visualization with GIF in center - matching device_found_screen container size
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 40),
            child: Container(
              width: isLargeTablet ? 420 : (isTablet ? 380 : 240),
              height: isLargeTablet ? 420 : (isTablet ? 380 : 240),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Phone image (left side) - increased size
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
                  
                  // Loading GIF (center) - increased size
                  Expanded(
                    child: Container(
                      height: isLargeTablet ? 120 : (isTablet ? 100 : 80),
                      child: Center(
                        child: Container(
                          width: isLargeTablet ? 100 : (isTablet ? 80 : 60),
                          height: isLargeTablet ? 100 : (isTablet ? 80 : 60),
                          child: Image.asset(
                            'assets/gifs/loading.gif',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: isLargeTablet ? 100 : (isTablet ? 80 : 60),
                                height: isLargeTablet ? 100 : (isTablet ? 80 : 60),
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
                  
                  // Device icon (right side) - increased size
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
          
          // Subtitle below the animation
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 40),
            child: Text(
              'Trying to Connect. Please Wait',
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