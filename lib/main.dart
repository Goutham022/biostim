import 'package:biostim/screens/foot_drop_rehab_page.dart';
import 'package:biostim/screens/shoulder_screen.dart';
import 'package:biostim/screens/shoulder_abduction_screen.dart';
import 'package:biostim/onboarding/intro_screen.dart';
import 'package:biostim/onboarding/intro_screen.dart';
import 'package:biostim/widgets/scanning_screen.dart';
import 'package:biostim/controllers/wifi_pairing_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait-only orientation lock
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    // DeviceOrientation.portraitDown, // Uncomment to allow upside-down portrait
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BioStim',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: ConnectionFailedScreen(controller: Get.put(WifiPairingController())),
      // home: const IntroScreen(),
      // home: DeviceFoundScreen(controller: Get.put(WifiPairingController())),
      //home: IntroScreen(),
      // home: IntroScreen(),
      // home: NotConnectedScreen(controller: Get.put(WifiPairingController())),
       home: const FootDropRehabPage()
      // home: const ShoulderAbductionPage(),
      // home: const IntroScreen(),
    );
  }
}
