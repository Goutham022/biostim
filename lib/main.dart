import 'package:biostim/screens/foot_drop_rehab_page.dart';
import 'package:biostim/widgets/connection_failed_screen.dart';
import 'package:biostim/widgets/connecting_screen.dart';
import 'package:biostim/widgets/device_found_screen.dart';
import 'package:flutter/material.dart';
import 'onboarding/intro_screen.dart';
import 'onboarding/device_instruction_screen.dart';
import 'screens/connected_screen.dart';
import 'screens/not_connected_screen.dart';
import 'controllers/wifi_pairing_controller.dart';
import 'package:get/get.dart';


void main() {
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
      // home: ConnectingScreen(controller: Get.put(WifiPairingController())),
       home: IntroScreen(),
      // home: NotConnectedScreen(controller: Get.put(WifiPairingController())),
      //  home: FootDropRehabPage(),
    );
  }
}

