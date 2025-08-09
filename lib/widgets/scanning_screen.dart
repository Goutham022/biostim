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
      child: Column(
        children: [
          // Title at the top
          Padding(
            padding: EdgeInsets.only(top: isTablet ? 80 : 60, right: isTablet ? 40 : 50),
            child: Text(
              'Scanning for devices ...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: isLargeTablet ? 28 : (isTablet ? 24 : 20),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF424242),
              ),
            ),
          ),

          // Spacing between title and animation
          SizedBox(height: isTablet ? 80 : 60),

          // Scanning animation in the middle
          Container(
            width: isLargeTablet ? 300 : (isTablet ? 250 : 200),
            height: isLargeTablet ? 300 : (isTablet ? 250 : 200),
            child: Image.asset(
              'assets/gifs/Searching_radius.gif',
              fit: BoxFit.contain,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: isLargeTablet ? 300 : (isTablet ? 250 : 200),
                  height: isLargeTablet ? 300 : (isTablet ? 250 : 200),
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
          
          // Spacing between animation and subtitle
          SizedBox(height: isTablet ? 100 : 80),
          
          // WiFi Status and Instructions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 40),
            child: Column(
              children: [
                // WiFi Status
                Obx(() => Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: controller.wifiEnabled.value ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: controller.wifiEnabled.value ? Colors.green[200]! : Colors.orange[200]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.wifiEnabled.value ? Icons.wifi : Icons.wifi_off,
                        size: 20,
                        color: controller.wifiEnabled.value ? Colors.green[600] : Colors.orange[600],
                      ),
                      SizedBox(width: 8),
                      Text(
                        controller.wifiEnabled.value ? 'WiFi Enabled' : 'Enabling WiFi...',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: controller.wifiEnabled.value ? Colors.green[700] : Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                )),
                
                SizedBox(height: 20),
                
                // Instructions
                Text(
                  'WiFi will be turned ON automatically',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: isLargeTablet ? 20 : (isTablet ? 18 : 16),
                    color: Colors.grey[600],
                  ),
                ),
                
                SizedBox(height: 10),
                
                Text(
                  'Please wait while we scan for your device',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: isLargeTablet ? 16 : (isTablet ? 14 : 12),
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // Spacer to push everything up
          Spacer(),
        ],
      ),
    );
  }
} 