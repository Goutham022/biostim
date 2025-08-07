import 'package:flutter/material.dart';

class NotConnectedScreen extends StatelessWidget {
  const NotConnectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Text(
                  'Biostep Playground',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Left Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Status - ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                                TextSpan(
                                  text: 'Not Connected',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFFF0000),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // Connect Button
                              Expanded(
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF333333),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        // TODO: Implement connect functionality
                                      },
                                      borderRadius: BorderRadius.circular(30),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.link,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Connect',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Refresh Button
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF333333),
                                  shape: BoxShape.circle,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      // TODO: Implement refresh functionality
                                    },
                                    borderRadius: BorderRadius.circular(22),
                                    child: const Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right Column - Device Image
                    Image.asset(
                      'assets/onboarding/device_icon_small.png',
                      width: 90,
                      height: 90,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 28),
              
              // Functional Electrical Stimulation Section
              _buildSection(
                'Functional Electrical Stimulation',
                [
                  _buildFeatureCard('Feature 1', 'assets/images/hand_press.png'),
                  _buildFeatureCard('Feature 2', 'assets/images/hand_tap.png'),
                  _buildFeatureCard('Feature 3', 'assets/images/hand_press.png'),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Biofeedback Section
              _buildSection(
                'Biofeedback',
                [
                  _buildFeatureCard('Feature 1', 'assets/images/hand_tap.png'),
                  _buildFeatureCard('Feature 2', 'assets/images/hand_press.png'),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // FES Games Section
              _buildSection(
                'FES Games',
                [
                  _buildFeatureCard('Game 1', 'assets/images/hand_press.png'),
                  _buildFeatureCard('Game 2', 'assets/images/hand_tap.png'),
                  _buildFeatureCard('Game 3', 'assets/images/hand_press.png'),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Biofeedback Games Section
              _buildSection(
                'Biofeedback Games',
                [
                  _buildFeatureCard('Game 1', 'assets/images/hand_tap.png'),
                  _buildFeatureCard('Game 2', 'assets/images/hand_press.png'),
                ],
              ),
              
              const SizedBox(height: 80), // Space for footer
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: const Color(0xFF2C2C2C),
        width: double.infinity,
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                color: Color(0xFF000000),
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              size: 20,
              color: Color(0xFF000000),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) => cards[index],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String imagePath) {
    return Container(
      width: 140,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to feature
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        color: Colors.grey,
                        size: 20,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF000000),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 