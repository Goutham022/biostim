import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wifi_pairing_controller.dart';

class ConnectingScreen extends StatefulWidget {
  final WifiPairingController controller;
  
  const ConnectingScreen({super.key, required this.controller});

  @override
  State<ConnectingScreen> createState() => _ConnectingScreenState();
}

class _ConnectingScreenState extends State<ConnectingScreen>
    with TickerProviderStateMixin {
  late AnimationController _dotController;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _dotAnimations = List.generate(5, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _dotController,
          curve: Interval(
            index * 0.1,
            (index + 1) * 0.1,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
    
    _dotController.repeat();
  }

  @override
  void dispose() {
    _dotController.dispose();
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Loading animation
          Container(
            width: isLargeTablet ? 200 : (isTablet ? 180 : 150),
            height: isLargeTablet ? 200 : (isTablet ? 180 : 150),
            child: Image.asset(
              'assets/gifs/loading.gif',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: isLargeTablet ? 200 : (isTablet ? 180 : 150),
                  height: isLargeTablet ? 200 : (isTablet ? 180 : 150),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                    ),
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: isTablet ? 80 : 60),
          
          // Connection visualization
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
                
                // Animated dots
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return AnimatedBuilder(
                        animation: _dotAnimations[index],
                        builder: (context, child) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            width: isLargeTablet ? 12 : (isTablet ? 10 : 8),
                            height: isLargeTablet ? 12 : (isTablet ? 10 : 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[400]!.withOpacity(
                                0.3 + (_dotAnimations[index].value * 0.7),
                              ),
                              shape: BoxShape.circle,
                            ),
                          );
                        },
                      );
                    }),
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