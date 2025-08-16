import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wifi_pairing_controller.dart';

class ScanningScreen extends StatelessWidget {
  final WifiPairingController controller;
  
  const ScanningScreen({super.key, required this.controller});
  
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
                'Scanning for devices',
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
          
          // Scanning animation with consistent padding
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 40),
            child: Container(
              width: isLargeTablet ? 420 : (isTablet ? 380 : 240),
              height: isLargeTablet ? 420 : (isTablet ? 380 : 240),
              child: Image.asset(
                'assets/gifs/Searching_radius.gif',
                fit: BoxFit.contain,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                      width: isLargeTablet ? 420 : (isTablet ? 380 : 240),
                      height: isLargeTablet ? 420 : (isTablet ? 380 : 240),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey[400]!,
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.wifi,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Scanning...',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: isTablet ? 18 : 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Spacing between animation and subtitle
          SizedBox(height: isTablet ? 120 : 100),
          
          // Subtitle below the animation
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 40),
            child: Text(
              'Make sure WiFi is turned ON ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
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