import 'package:flutter/material.dart';
import 'onboarding/intro_screen.dart';
import 'onboarding/device_instruction_screen.dart';
import 'screens/connected_screen.dart';
import 'screens/not_connected_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BioStim',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
       home: const ConnectedScreen(),
      // home: const NotConnectedScreen(),
    );
  }
}
