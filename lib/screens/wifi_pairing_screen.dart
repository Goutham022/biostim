import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wifi_pairing_controller.dart';
import '../widgets/scanning_screen.dart';
import '../widgets/device_found_screen.dart';
import '../widgets/connecting_screen.dart';
import '../widgets/connection_success_screen.dart';
import '../widgets/device_not_found_screen.dart';
import '../widgets/connection_failed_screen.dart';

class WifiPairingScreen extends StatelessWidget {
  const WifiPairingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WifiPairingController());
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          switch (controller.currentScreen.value) {
            case 'scanning':
              return ScanningScreen(controller: controller);
            case 'device_found':
              return DeviceFoundScreen(controller: controller);
            case 'connecting':
              return ConnectingScreen(controller: controller);
            case 'connection_success':
              return ConnectionSuccessScreen(controller: controller);
            case 'device_not_found':
              return DeviceNotFoundScreen(controller: controller);
            case 'connection_failed':
              return ConnectionFailedScreen(controller: controller);
            default:
              return ScanningScreen(controller: controller);
          }
        }),
      ),
    );
  }
} 