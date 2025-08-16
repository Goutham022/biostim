import 'package:flutter/material.dart';
import 'foot_drop_rehab_page.dart';

class ConnectedScreen extends StatelessWidget {
  const ConnectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargeTablet = screenSize.width > 900;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Main scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Padding(
                      padding: EdgeInsets.only(top: isTablet ? 32 : 24, bottom: isTablet ? 32 : 24),
                      child: Text(
                        'Biostep Playground',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ),
                    
                    // Rehab Physio Device Info Card
                    Container(
                      margin: EdgeInsets.only(bottom: isTablet ? 32 : 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(isLargeTablet ? 24 : (isTablet ? 22 : 20)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(18, 0, 0, 0),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isLargeTablet ? 24 : (isTablet ? 20 : 16)),
                        child: Row(
                          children: [
                            // Left Section - Device Info
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title
                                  Text(
                                    'Rehab Physio',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF333333),
                                    ),
                                  ),
                                  SizedBox(height: isTablet ? 12 : 8),
                                  
                                  // Status
                                  Row(
                                    children: [
                                      Text(
                                        'Status - ',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: isLargeTablet ? 18 : (isTablet ? 16 : 14),
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        'Connected',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize:14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isTablet ? 8 : 6),
                                  
                                  // Warranty
                                  Text(
                                    'Warranty validity - 4/06/26',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: isLargeTablet ? 16 : (isTablet ? 14 : 12),
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: isTablet ? 16 : 12),
                                  
                                  // Battery Indicator
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.battery_1_bar_outlined,
                                        size: isLargeTablet ? 24 : (isTablet ? 22 : 20),
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: isTablet ? 12 : 8),
                                      Expanded(
                                        child: LinearProgressIndicator(
                                          value: 0.15,
                                          backgroundColor: Colors.grey[300],
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                                        ),
                                      ),
                                      SizedBox(width: isTablet ? 12 : 8),
                                      Text(
                                        '15%',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: isLargeTablet ? 16 : (isTablet ? 14 : 12),
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            SizedBox(width: isTablet ? 20 : 16),
                            
                            // Right Section - Device Image
                            Container(
                              width: isLargeTablet ? 110 : (isTablet ? 100 : 90),
                              height: isLargeTablet ? 110 : (isTablet ? 100 : 90),
                              child: Image.asset(
                                'assets/onboarding/device_icon_small.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(isLargeTablet ? 12 : (isTablet ? 10 : 8)),
                                    ),
                                    child: Icon(
                                      Icons.medical_services,
                                      size: isLargeTablet ? 48 : (isTablet ? 44 : 40),
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
                    
                    // Functional Electrical Stimulation Section
                    _buildSection(
                      context,
                      'Functional Electrical Stimulation',
                      isTablet,
                      isLargeTablet,
                      [
                        _buildDetailedCard(
                          context,
                          'Foot Drop Rehab',
                          'Stimulates while walking',
                          'Helps in Gait improvement',
                          isTablet,
                          isLargeTablet,
                        ),
                        SizedBox(width: isTablet ? 16 : 12),
                        _buildSimpleCard(
                          context,
                          'Foot Drop Rehab',
                          isTablet,
                          isLargeTablet,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: isTablet ? 20 : 16),
                    
                    // Biofeedback Section
                    _buildSection(
                      context,
                      'Biofeedback',
                      isTablet,
                      isLargeTablet,
                      [
                        _buildPlaceholderCard(isTablet, isLargeTablet),
                        SizedBox(width: isTablet ? 16 : 12),
                        _buildPlaceholderCard(isTablet, isLargeTablet),
                        SizedBox(width: isTablet ? 16 : 12),
                        _buildPlaceholderCard(isTablet, isLargeTablet),
                      ],
                    ),
                    
                    SizedBox(height: isTablet ? 20 : 16),
                    
                    // FES Games Section
                    _buildSection(
                      context,
                      'FES Games',
                      isTablet,
                      isLargeTablet,
                      [
                        _buildPlaceholderCard(isTablet, isLargeTablet),
                        SizedBox(width: isTablet ? 16 : 12),
                        _buildPlaceholderCard(isTablet, isLargeTablet),
                      ],
                    ),
                    
                    SizedBox(height: isTablet ? 20 : 16),
                    
                    // Biofeedback Games Section
                    _buildSection(
                      context,
                      'Biofeedback Games',
                      isTablet,
                      isLargeTablet,
                      [
                        _buildPlaceholderCard(isTablet, isLargeTablet),
                        SizedBox(width: isTablet ? 16 : 12),
                        _buildPlaceholderCard(isTablet, isLargeTablet),
                        SizedBox(width: isTablet ? 16 : 12),
                        _buildPlaceholderCard(isTablet, isLargeTablet),
                      ],
                    ),
                    
                    // Bottom padding for footer
                    SizedBox(height: isTablet ? 32 : 24),
                  ],
                ),
              ),
            ),
            
            // Dark Footer
            Container(
              height: isLargeTablet ? 80 : (isTablet ? 70 : 60),
              color: const Color(0xFF2C2C2C),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(
    BuildContext context,
    String title,
    bool isTablet,
    bool isLargeTablet,
    List<Widget> cards,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title with Arrow
        Padding(
          padding: EdgeInsets.only(bottom: isTablet ? 16 : 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
              ),
              Icon(
                Icons.arrow_forward,
                size: 20,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
        
        // Cards Row
        Row(
          children: cards,
        ),
      ],
    );
  }
  
  Widget _buildDetailedCard(
    BuildContext context,
    String title,
    String subtitle1,
    String subtitle2,
    bool isTablet,
    bool isLargeTablet,
  ) {
    return Expanded(
      child: Container(
        height: isLargeTablet ? 120 : (isTablet ? 110 : 100),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isLargeTablet ? 12 : (isTablet ? 10 : 8)),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(18, 0, 0, 0),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Navigate to Foot Drop Rehab page when tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FootDropRehabPage(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(isLargeTablet ? 12 : (isTablet ? 10 : 8)),
            child: Padding(
              padding: EdgeInsets.all(isLargeTablet ? 16 : (isTablet ? 14 : 12)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Custom Icon (Walking + Lightning)
                  Container(
                    width: isLargeTablet ? 32 : (isTablet ? 28 : 24),
                    height: isLargeTablet ? 32 : (isTablet ? 28 : 24),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.directions_walk,
                          size: isLargeTablet ? 32 : (isTablet ? 28 : 24),
                          color: const Color(0xFF333333),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Icon(
                            Icons.flash_on,
                            size: isLargeTablet ? 16 : (isTablet ? 14 : 12),
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isTablet ? 8 : 6),
                  
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: isLargeTablet ? 16 : (isTablet ? 14 : 12),
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isTablet ? 4 : 2),
                  
                  // Subtitles
                  Text(
                    subtitle1,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: isLargeTablet ? 12 : (isTablet ? 10 : 8),
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    subtitle2,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: isLargeTablet ? 12 : (isTablet ? 10 : 8),
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSimpleCard(
    BuildContext context,
    String title,
    bool isTablet,
    bool isLargeTablet,
  ) {
    return Expanded(
      child: Container(
        height: isLargeTablet ? 120 : (isTablet ? 110 : 100),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isLargeTablet ? 12 : (isTablet ? 10 : 8)),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(18, 0, 0, 0),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isLargeTablet ? 16 : (isTablet ? 14 : 12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Custom Icon (Walking + Lightning)
              Container(
                width: isLargeTablet ? 32 : (isTablet ? 28 : 24),
                height: isLargeTablet ? 32 : (isTablet ? 28 : 24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.directions_walk,
                      size: isLargeTablet ? 32 : (isTablet ? 28 : 24),
                      color: const Color(0xFF333333),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(
                        Icons.flash_on,
                        size: isLargeTablet ? 16 : (isTablet ? 14 : 12),
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 8 : 6),
              
              // Title
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: isLargeTablet ? 16 : (isTablet ? 14 : 12),
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPlaceholderCard(bool isTablet, bool isLargeTablet) {
    return Expanded(
      child: Container(
        width: isLargeTablet ? 160 : (isTablet ? 150 : 140),
        height: isLargeTablet ? 120 : (isTablet ? 110 : 100),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isLargeTablet ? 12 : (isTablet ? 10 : 8)),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(18, 0, 0, 0),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.add,
            size: isLargeTablet ? 32 : (isTablet ? 28 : 24),
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }
} 