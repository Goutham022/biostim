import 'package:flutter/material.dart';

class DeviceInstructionScreen extends StatelessWidget {
  const DeviceInstructionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargeTablet = screenSize.width > 900;
    
    // Calculate responsive values
    final horizontalPadding = isLargeTablet ? 80.0 : (isTablet ? 40.0 : 20.0);
    final maxContentWidth = isLargeTablet ? 800.0 : (isTablet ? 600.0 : double.infinity);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      SizedBox(height: isTablet ? 40 : 0),
                      
                      // First Instruction
                      _buildInstructionStep(
                        context: context,
                        instruction: "Turn on device by pressing the round button once.",
                        gifAsset: 'assets/gifs/power_button.gif',
                      ),
                      
                      SizedBox(height: isTablet ? 60 : 0),
                      
                      // Second Instruction
                      _buildInstructionStep(
                        context: context,
                        instruction: "Hold UP button for 1 sec to turn on Pairing Mode.",
                        gifAsset: 'assets/gifs/pairing_button.gif',
                      ),
                      
                      SizedBox(height: isTablet ? 120 : 100), // Add space for the floating button
                    ],
                  ),
                ),
              ),
            ),
            
            // Floating Next Button in bottom right
            Positioned(
              bottom: isTablet ? 50 : 30,
              right: isTablet ? 50 : 20,
              child: _buildNextButton(context),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildInstructionStep({
    required BuildContext context,
    required String instruction,
    required String gifAsset,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargeTablet = screenSize.width > 900;
    
    // Calculate responsive values
    final fontSize = isLargeTablet ? 24.0 : (isTablet ? 20.0 : 18.0);
    final containerHeight = isLargeTablet ? 300.0 : (isTablet ? 250.0 : 200.0);
    final gifHeight = isLargeTablet ? 280.0 : (isTablet ? 230.0 : 180.0);
    final spacing = isTablet ? 30.0 : 20.0;
    
    return Column(
      children: [
        // Instruction Text
        Text(
          instruction,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: fontSize,
            fontWeight: FontWeight.normal,
            color: const Color(0xFF424242),
            height: 1.4,
            letterSpacing: 0.3,
          ),
        ),
        
        SizedBox(height: spacing),
        
                 // GIF Container
         Container(
           width: double.infinity,
           height: containerHeight,
           child: Center(
             child: Container(
               height: gifHeight,
               child: Image.asset(
                 gifAsset,
                 fit: BoxFit.contain,
                 gaplessPlayback: true,
                 errorBuilder: (context, error, stackTrace) {
                   return Center(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(
                           Icons.image_not_supported,
                           size: isTablet ? 70 : 50,
                           color: Colors.grey[400],
                         ),
                         SizedBox(height: 10),
                         Text(
                           'Image not available',
                           style: TextStyle(
                             fontFamily: 'Montserrat',
                             fontSize: isTablet ? 16 : 14,
                             color: Colors.grey[600],
                           ),
                         ),
                       ],
                     ),
                   );
                 },
               ),
             ),
           ),
         ),
      ],
    );
  }

  Widget _buildNextButton(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargeTablet = screenSize.width > 900;
    
    // Calculate responsive button size
    final buttonWidth = isLargeTablet ? 150.0 : (isTablet ? 140.0 : 120.0);
    final buttonHeight = isLargeTablet ? 60.0 : (isTablet ? 55.0 : 50.0);
    final fontSize = isLargeTablet ? 18.0 : (isTablet ? 17.0 : 16.0);
    final iconSize = isLargeTablet ? 20.0 : (isTablet ? 19.0 : 18.0);
    
    return Container(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          // Handle next action
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF424242),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonHeight / 2),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Next',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: isTablet ? 8 : 6),
            Icon(
              Icons.arrow_forward,
              size: iconSize,
            ),
          ],
        ),
      ),
    );
  }
} 