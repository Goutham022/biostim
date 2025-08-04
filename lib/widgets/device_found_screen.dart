import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../controllers/wifi_pairing_controller.dart';

class DeviceFoundScreen extends StatefulWidget {
  final WifiPairingController controller;
  
  const DeviceFoundScreen({super.key, required this.controller});

  @override
  State<DeviceFoundScreen> createState() => _DeviceFoundScreenState();
}

class _DeviceFoundScreenState extends State<DeviceFoundScreen>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
    _rippleController.repeat();
    
    // Start 30-second timeout timer
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        widget.controller.currentScreen.value = 'connection_failed';
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargeTablet = screenSize.width > 900;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.only(left: 10, top: 32),
          child: Text(
            'Scanning for Devices...',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w100,
              fontSize: isLargeTablet ? 28 : (isTablet ? 22 : 20),
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Device icon with animated ripples
            GestureDetector(
              onTap: () {
                _timeoutTimer?.cancel(); // Cancel timeout when user taps
                widget.controller.startConnection();
              },
              child: Container(
                width: isLargeTablet ? 200 : (isTablet ? 180 : 150),
                height: isLargeTablet ? 200 : (isTablet ? 180 : 150),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Animated ripples
                    AnimatedBuilder(
                      animation: _rippleAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(
                            isLargeTablet ? 200 : (isTablet ? 180 : 150),
                            isLargeTablet ? 200 : (isTablet ? 180 : 150),
                          ),
                          painter: RipplePainter(
                            animation: _rippleAnimation,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        );
                      },
                    ),
                    
                    // Device icon
                    Container(
                      width: isLargeTablet ? 120 : (isTablet ? 100 : 80),
                      height: isLargeTablet ? 120 : (isTablet ? 100 : 80),
                      child: Image.asset(
                        'assets/onboarding/device_icon.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: isLargeTablet ? 120 : (isTablet ? 100 : 80),
                            height: isLargeTablet ? 120 : (isTablet ? 100 : 80),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
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
            
            // Text
            Text(
              'Device Found. Tap to Connect',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: isLargeTablet ? 24 : (isTablet ? 20 : 18),
                fontWeight: FontWeight.w400,
                color: const Color(0xFF424242),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for animated ripples
class RipplePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  RipplePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * animation.value;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) => true;
} 