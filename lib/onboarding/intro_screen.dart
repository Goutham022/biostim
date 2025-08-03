import 'package:flutter/material.dart';
import 'device_instruction_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargeTablet = screenSize.width > 900;
    
    // Calculate responsive values
    final horizontalPadding = isLargeTablet ? 80.0 : (isTablet ? 40.0 : 24.0);
    final maxContentWidth = isLargeTablet ? 800.0 : (isTablet ? 600.0 : double.infinity);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: [
                  SizedBox(height: isTablet ? 40 : 20),
                  
                  // Top Section (Branding)
                  _buildBrandingSection(context),
                  
                  SizedBox(height: isTablet ? 50 : 30),
                  
                  // Image Section
                  Expanded(
                    flex: 2,
                    child: _buildImageSection(context),
                  ),
                  
                  SizedBox(height: isTablet ? 40 : 20),
                  
                  // Motivational Text
                  _buildMotivationalText(context),
                  
                  SizedBox(height: isTablet ? 50 : 30),
                  
                  // Get Started Button
                  _buildGetStartedButton(context),
                  
                  SizedBox(height: isTablet ? 40 : 20),
                  
                  // Footer Section
                  _buildFooterSection(context),
                  
                  SizedBox(height: isTablet ? 20 : 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingSection(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargeTablet = screenSize.width > 900;
    
    final logoHeight = isLargeTablet ? 120.0 : (isTablet ? 110.0 : 90.0);
    final fontSize = isLargeTablet ? 20.0 : (isTablet ? 18.0 : 16.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo image aligned to the left
        Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/onboarding/biostep_plus_logo.png',
            height: logoHeight,
            fit: BoxFit.contain,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: isTablet ? 20.0 : 16.0),
            child: Text(
              'FES system',
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Image.asset(
          'assets/onboarding/device.png',
          fit: BoxFit.contain,
          alignment: Alignment.centerRight,
        ),
      ),
    );
  }
  }
  

  Widget _buildMotivationalText(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargeTablet = screenSize.width > 900;
    
    final fontSize = isLargeTablet ? 28.0 : (isTablet ? 24.0 : 20.0);
    
    return Text(
      'Take the First Step in\n     Your Journey to\n     Recovery',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.normal,
        fontSize: fontSize,
        color: const Color(0xFF424242),
        height: 1.3,
        letterSpacing: 0.5,
      ),
    );
  }
  // const SizedBox(height: 20);

  Widget _buildGetStartedButton(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargeTablet = screenSize.width > 900;
    
    final buttonHeight = isLargeTablet ? 60.0 : (isTablet ? 55.0 : 46.0);
    final fontSize = isLargeTablet ? 20.0 : (isTablet ? 19.0 : 18.0);
    final iconSize = isLargeTablet ? 22.0 : (isTablet ? 21.0 : 20.0);
    
    return Container(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DeviceInstructionScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF424242),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonHeight / 2),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Get Started',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: isTablet ? 10 : 8),
            Icon(
              Icons.arrow_forward,
              size: iconSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Made with ❤️ in 🇮🇳',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'A Product by ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
            Image.asset(
              'assets/onboarding/bs_logo3_crop.jpg',
              height: 40,
              width: 40,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ],
    );
  }
