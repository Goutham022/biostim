import 'package:flutter/material.dart';

class ShoulderAbductionPage extends StatefulWidget {
  const ShoulderAbductionPage({super.key});

  @override
  State<ShoulderAbductionPage> createState() => _ShoulderAbductionPageState();
}

class _ShoulderAbductionPageState extends State<ShoulderAbductionPage>
    with TickerProviderStateMixin {
  double stimulationValue = 10.0;
  double angleValue = -12.5;
  double triggerAngleValue = 15.0;
  bool isPlaying = false;
  String selectedDuration = '1';
  String selectedPulseWidth = '100';

  // Overlay rotation state
  final ValueNotifier<double> overlayAngleRad = ValueNotifier(0.0);

  final List<String> durationOptions = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10'
  ];
  final List<String> pulseWidthOptions = ['100', '200', '300', '400', '500'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Helper methods for overlay rotation
  void setOverlayAngleDegrees(double deg) {
    overlayAngleRad.value = deg * (3.14159 / 180.0); // Convert degrees to radians
  }

  void setOverlayAngleRadians(double rad) {
    overlayAngleRad.value = rad;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Shoulder Abduction',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 16),

              // Top Card (Stacked Images)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTablet = constraints.maxWidth > 600;
                  final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

                  // Card width logic
                  double maxCardWidth = isTablet ? 900 : 1200;
                  double cardWidth = constraints.maxWidth < maxCardWidth
                      ? constraints.maxWidth
                      : maxCardWidth;

                  // Card height logic
                  double cardHeight;
                  if (isTablet) {
                    cardHeight = isLandscape ? 600 : 680;
                  } else {
                    double screenHeight = MediaQuery.of(context).size.height;
                    cardHeight = (screenHeight * 0.98).clamp(200.0, 300.0);
                  }

                  // In landscape, further limit height to avoid overflow
                  if (isLandscape) {
                    double availableHeight = MediaQuery.of(context).size.height * 0.5;
                    if (cardHeight > availableHeight) {
                      cardHeight = availableHeight;
                    }
                  }

                  return Center(
                    child: Container(
                      width: cardWidth,
                      height: cardHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(18, 0, 0, 0),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.only(left: 0, top: 10, right: 0, bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            // Background image fills the card, moved further to the left
                            Positioned(
                              left: -100,
                              top: 5,
                              bottom: 5,
                              child: Image.asset(
                                'assets/images/home_tab/biofeedback/Background[1].png',
                                height: cardHeight,
                                width: cardWidth,
                                // fit: BoxFit.cover,
                                // height: 300,
                                // width: 300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Live Angle and Trigger Angle Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(18, 0, 0, 0),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Angle',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${angleValue.toStringAsFixed(1)}°',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF333333),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextButton(
                              onPressed: () {
                                setOverlayAngleDegrees(-90);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                              child: const Text(
                                'Calibrate',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(18, 0, 0, 0),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Center(
                            child: Text(
                              'Set Target Angle',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF000000),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${triggerAngleValue.toStringAsFixed(1)}°',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            height: 32,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF333333),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextButton(
                              onPressed: () {
                                // Handle set angle
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                              child: const Text(
                                'Set Angle',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Three cards in a row: Timer, Hold Time, Repetitions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Timer Card
                  Expanded(
                    child: Container(
                      height: 100,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(18, 0, 0, 0),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Timer',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Transform.translate(
                            offset: const Offset(0, 2),
                            child: Card(
                              color: Colors.grey[100],
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 0.0),
                                child: SizedBox(
                                  height: 32,
                                  width: 60,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedDuration == 'NA' ? null : selectedDuration,
                                      hint: const Text(
                                        'NA',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      items: [
                                        const DropdownMenuItem(
                                          value: 'NA',
                                          child: Text('NA', style: TextStyle(fontSize: 12)),
                                        ),
                                        const DropdownMenuItem(
                                          value: '1',
                                          child: Text('1 Min', style: TextStyle(fontSize: 12)),
                                        ),
                                        const DropdownMenuItem(
                                          value: '2',
                                          child: Text('2 Min', style: TextStyle(fontSize: 12)),
                                        ),
                                        const DropdownMenuItem(
                                          value: '3',
                                          child: Text('3 Min', style: TextStyle(fontSize: 12)),
                                        ),
                                        const DropdownMenuItem(
                                          value: '4',
                                          child: Text('4 Min', style: TextStyle(fontSize: 12)),
                                        ),
                                        const DropdownMenuItem(
                                          value: '5',
                                          child: Text('5 Min', style: TextStyle(fontSize: 12)),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          selectedDuration = value ?? 'NA';
                                        });
                                      },
                                      isExpanded: true,
                                      iconSize: 18,
                                      style: const TextStyle(fontSize: 12, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  
                  // Hold Time Card
                  Expanded(
                    child: Container(
                      height: 120,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(18, 0, 0, 0),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Hold Time',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Transform.translate(
                            offset: const Offset(0, -2),
                            child: Card(
                              color: Colors.grey[100],
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 0.0),
                                child: SizedBox(
                                  height: 32,
                                  width: 60,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      hint: const Text(
                                        'NA',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'NA',
                                          child: Text('NA', style: TextStyle(fontSize: 12)),
                                        ),
                                        DropdownMenuItem(
                                          value: '1',
                                          child: Text('0', style: TextStyle(fontSize: 12)),
                                        ),
                                        DropdownMenuItem(
                                          value: '2',
                                          child: Text('1', style: TextStyle(fontSize: 12)),
                                        ),
                                        DropdownMenuItem(
                                          value: '3',
                                          child: Text('2', style: TextStyle(fontSize: 12)),
                                        ),
                                        DropdownMenuItem(
                                          value: '4',
                                          child: Text('3', style: TextStyle(fontSize: 12)),
                                        ),
                                        DropdownMenuItem(
                                          value: '5',
                                          child: Text('4', style: TextStyle(fontSize: 12)),
                                        ),
                                        DropdownMenuItem(
                                          value: '6',
                                          child: Text('5', style: TextStyle(fontSize: 12)),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          // Handle hold time selection
                                        });
                                      },
                                      iconSize: 18,
                                      style: const TextStyle(fontSize: 12, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  
                  // Repetitions Card
                  Expanded(
                    child: Container(
                      height: 100,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(18, 0, 0, 0),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Repetitions',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Transform.translate(
                            offset: const Offset(0, 2),
                            child: Card(
                              color: Colors.grey[100],
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
                                child: SizedBox(
                                  height: 32,
                                  width: 60,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      hint: const Text(
                                        'NA',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'NA',
                                          child: Text('NA', style: TextStyle(fontSize: 12)),
                                        ),
                                        DropdownMenuItem(
                                          value: '1',
                                          child: Text('5', style: TextStyle(fontSize: 12)),
                                        ),
                                        DropdownMenuItem(
                                          value: '2',
                                          child: Text('10', style: TextStyle(fontSize: 12)),
                                        ),
                                        DropdownMenuItem(
                                          value: '3',
                                          child: Text('15', style: TextStyle(fontSize: 12)),
                                        ),
                                        DropdownMenuItem(
                                          value: '4',
                                          child: Text('20', style: TextStyle(fontSize: 12)),
                                        ),
                                        DropdownMenuItem(
                                          value: '5',
                                          child: Text('25', style: TextStyle(fontSize: 12)),
                                        ),
                                        DropdownMenuItem(
                                          value: '6',
                                          child: Text('30', style: TextStyle(fontSize: 12)),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          // Handle repetitions selection
                                        });
                                      },
                                      iconSize: 18,
                                      style: const TextStyle(fontSize: 12, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Start Program Button
              Container(
                width: double.infinity,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  onPressed: () {
                    // Handle start program
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Start Program',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
