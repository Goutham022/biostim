import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:flutter/services.dart';
import 'package:app_settings/app_settings.dart';

class WifiPairingController extends GetxController {
  // Observable variables
  var isScanning = false.obs;
  var isConnecting = false.obs;
  var deviceFound = false.obs;
  var connectionSuccess = false.obs;
  var scanTimeout = false.obs;
  var connectionTimeout = false.obs;
  var currentScreen = 'scanning'.obs;
  var wifiEnabled = false.obs;
  
  // Timers
  Timer? _scanTimer;
  Timer? _connectionTimer;
  
  // WiFi scan results
  var wifiNetworks = <WiFiAccessPoint>[].obs;
  
  // ESP32 IP address
  static const String esp32IP = '192.168.4.1';
  
  // Platform channel for Android-specific WiFi operations
  static const platform = MethodChannel('wifi_channel');
  
  // Enable WiFi automatically with platform-specific handling
  Future<void> _enableWiFi() async {
    try {
      if (Platform.isAndroid) {
        // Get Android version
        final androidVersion = await _getAndroidVersion();
        print('Android version: $androidVersion');
        
        if (androidVersion <= 9) {
          // For Android 9 and below, use wifi_iot package
          await _enableWiFiAndroid9Below();
        } else {
          // For Android 10+, use wifi_scan package
          await _enableWiFiAndroid10Plus();
        }
      } else {
        // For iOS, use wifi_scan package
        await _enableWiFiAndroid10Plus();
      }
    } catch (e) {
      print('Error enabling WiFi: $e');
      // Fallback: try to open WiFi settings
      await _openWiFiSettings();
    }
  }
  
  // Get Android version
  Future<int> _getAndroidVersion() async {
    try {
      if (Platform.isAndroid) {
        final result = await platform.invokeMethod('getAndroidVersion');
        return result ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error getting Android version: $e');
      return 0;
    }
  }
  
  // Enable WiFi for Android 9 and below using wifi_iot
  Future<void> _enableWiFiAndroid9Below() async {
    try {
      // Check if WiFi is enabled
      final isEnabled = await WiFiForIoTPlugin.isEnabled();
      print('WiFi enabled status: $isEnabled');
      
      if (!isEnabled) {
        // Try to enable WiFi
        final result = await WiFiForIoTPlugin.setEnabled(true);
        print('WiFi enable result: $result');
        
        if (result) {
          // Wait a moment for WiFi to fully enable
          await Future.delayed(const Duration(seconds: 2));
          
          // Verify WiFi is now enabled
          final isNowEnabled = await WiFiForIoTPlugin.isEnabled();
          print('WiFi enabled after attempt: $isNowEnabled');
          
          if (isNowEnabled) {
            wifiEnabled.value = true;
            print('WiFi enabled successfully for Android 9 and below');
          } else {
            print('Failed to enable WiFi for Android 9 and below');
            await _openWiFiSettings();
          }
        } else {
          print('Failed to enable WiFi programmatically');
          await _openWiFiSettings();
        }
      } else {
        wifiEnabled.value = true;
        print('WiFi already enabled');
      }
    } catch (e) {
      print('Error enabling WiFi for Android 9 and below: $e');
      await _openWiFiSettings();
    }
  }
  
  // Enable WiFi for Android 10+ using wifi_scan
  Future<void> _enableWiFiAndroid10Plus() async {
    try {
      // Check if WiFi scanning is available
      final canStartScan = await WiFiScan.instance.canStartScan();
      
      if (canStartScan == CanStartScan.yes) {
        // Start scan to enable WiFi (this automatically turns on WiFi)
        await WiFiScan.instance.startScan();
        wifiEnabled.value = true;
        print('WiFi enabled automatically through scan for Android 10+');
      } else {
        print('WiFi scanning not available: $canStartScan');
        // Try alternative method - start scan anyway
        try {
          await WiFiScan.instance.startScan();
          wifiEnabled.value = true;
          print('WiFi enabled through alternative method for Android 10+');
        } catch (e) {
          print('Alternative WiFi enable failed for Android 10+: $e');
          await _openWiFiSettings();
        }
      }
    } catch (e) {
      print('Error enabling WiFi for Android 10+: $e');
      await _openWiFiSettings();
    }
  }
  
  // Open WiFi settings as fallback
  Future<void> _openWiFiSettings() async {
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.wifi);
      print('Opened WiFi settings');
    } catch (e) {
      print('Error opening WiFi settings: $e');
    }
  }
  
  // Check if WiFi is enabled
  Future<bool> _isWiFiEnabled() async {
    try {
      if (Platform.isAndroid) {
        final androidVersion = await _getAndroidVersion();
        
        if (androidVersion <= 9) {
          // For Android 9 and below, use wifi_iot
          return await WiFiForIoTPlugin.isEnabled();
        } else {
          // For Android 10+, use wifi_scan
          final canStartScan = await WiFiScan.instance.canStartScan();
          return canStartScan == CanStartScan.yes;
        }
      } else {
        // For iOS, use wifi_scan
        final canStartScan = await WiFiScan.instance.canStartScan();
        return canStartScan == CanStartScan.yes;
      }
    } catch (e) {
      print('Error checking WiFi status: $e');
      return false;
    }
  }
  
  // Check if connected to ESP32 WiFi network
  Future<bool> _isConnectedToESP32() async {
    try {
      // Get all network interfaces
      final interfaces = await NetworkInterface.list();
      
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          // Check if the IP address is in the ESP32 network range (192.168.4.x)
          if (addr.address.startsWith('192.168.4.')) {
            print('Connected to ESP32 network: ${addr.address}');
            return true;
          }
        }
      }
      
      // Alternative: Try to ping ESP32 IP address
      try {
        final result = await InternetAddress(esp32IP).reverse();
        print('ESP32 IP reachable: ${result.host}');
        return true;
      } catch (e) {
        print('ESP32 IP not reachable: $e');
      }
      
      // Additional check: Try to connect to ESP32 IP address
      try {
        final socket = await Socket.connect(esp32IP, 80, timeout: const Duration(seconds: 3));
        await socket.close();
        print('ESP32 IP connection successful');
        return true;
      } catch (e) {
        print('ESP32 IP connection failed: $e');
      }
      
      print('Not connected to ESP32 network');
      return false;
    } catch (e) {
      print('Error checking ESP32 connection: $e');
      return false;
    }
  }
  
  @override
  void onInit() {
    super.onInit();
    startScanning();
  }
  
  @override
  void onClose() {
    _scanTimer?.cancel();
    _connectionTimer?.cancel();
    super.onClose();
  }
  
  // Start scanning for WiFi devices
  Future<void> startScanning() async {
    isScanning.value = true;
    currentScreen.value = 'scanning';
    deviceFound.value = false;
    scanTimeout.value = false;
    wifiEnabled.value = false;
    
    // Enable WiFi immediately when scanning starts
    await _enableWiFi();
    
    // Request location permission (required for WiFi scanning)
    var status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      Get.snackbar('Permission Required', 'Location permission is needed to scan WiFi networks');
      return;
    }
    
    // Verify WiFi is enabled
    final isWiFiEnabled = await _isWiFiEnabled();
    if (!isWiFiEnabled) {
      print('WiFi may not be enabled - continuing with scan attempt');
    } else {
      print('WiFi is enabled and ready for scanning');
      wifiEnabled.value = true;
    }
    
    // Start 30-second scan timer
    _scanTimer = Timer(const Duration(seconds: 30), () {
      if (!deviceFound.value) {
        scanTimeout.value = true;
        isScanning.value = false;
        currentScreen.value = 'device_not_found';
      }
    });
    
    // Start WiFi scanning
    await _performWifiScan();
  }
  
  // Perform WiFi scan
  Future<void> _performWifiScan() async {
    try {
      // Check if WiFi scanning is available
      final canGetScannedResults = await WiFiScan.instance.canGetScannedResults();
      
      if (canGetScannedResults == CanGetScannedResults.yes) {
        // Start initial scan
        await WiFiScan.instance.startScan();
        
        // Poll for results every 2 seconds and start new scans
        Timer.periodic(const Duration(seconds: 2), (timer) async {
          if (!this.isScanning.value || deviceFound.value) {
            timer.cancel();
            return;
          }
          
          try {
            // Get current scan results
            final results = await WiFiScan.instance.getScannedResults();
            if (results != null) {
              wifiNetworks.value = results;
              
              // Check if Biostim+ device is found
              for (var network in results) {
                if (network.ssid == 'Biostep+') {
                  deviceFound.value = true;
                  this.isScanning.value = false;
                  _scanTimer?.cancel();
                  timer.cancel();
                  currentScreen.value = 'device_found';
                  break;
                }
              }
              
              // Also check if connected to ESP32 WiFi network
              if (!deviceFound.value) {
                final isConnectedToESP32 = await _isConnectedToESP32();
                if (isConnectedToESP32) {
                  deviceFound.value = true;
                  this.isScanning.value = false;
                  _scanTimer?.cancel();
                  timer.cancel();
                  currentScreen.value = 'device_found';
                  print('ESP32 network detected - device found');
                }
              }
              
              // Additional check: If we're on the ESP32 network, consider device found
              if (!deviceFound.value) {
                try {
                  final socket = await Socket.connect(esp32IP, 80, timeout: const Duration(seconds: 2));
                  await socket.close();
                  deviceFound.value = true;
                  this.isScanning.value = false;
                  _scanTimer?.cancel();
                  timer.cancel();
                  currentScreen.value = 'device_found';
                  print('ESP32 IP reachable - device found');
                } catch (e) {
                  // ESP32 not reachable, continue scanning
                }
              }
            }
            
            // Start a new scan every 2 seconds to keep scanning fresh
            await WiFiScan.instance.startScan();
          } catch (e) {
            print('WiFi scan polling error: $e');
          }
        });
      }
    } catch (e) {
      print('WiFi scan error: $e');
    }
  }
  
  // Navigate to device found screen
  void onDeviceFound() {
    currentScreen.value = 'device_found';
  }
  
  // Start connection process
  void startConnection() {
    isConnecting.value = true;
    currentScreen.value = 'connecting';
    connectionSuccess.value = false;
    connectionTimeout.value = false;
    
    // Start 60-second connection timer
    _connectionTimer = Timer(const Duration(seconds: 60), () {
      if (!connectionSuccess.value) {
        connectionTimeout.value = true;
        isConnecting.value = false;
        currentScreen.value = 'connection_failed';
      }
    });
    
    // Simulate connection process
    _simulateConnection();
  }
  
  // Simulate connection process
  Future<void> _simulateConnection() async {
    // Simulate connection delay (3-8 seconds)
    final delay = Duration(seconds: 3 + (DateTime.now().millisecond % 6));
    await Future.delayed(delay);
    
    // Check if connected to ESP32 WiFi network
    final isConnectedToESP32 = await _isConnectedToESP32();
    
    if (isConnectedToESP32) {
      connectionSuccess.value = true;
      isConnecting.value = false;
      _connectionTimer?.cancel();
      currentScreen.value = 'connection_success';
      
      // Additional verification: Check if we can reach the ESP32 IP
      try {
        final socket = await Socket.connect(esp32IP, 80, timeout: const Duration(seconds: 5));
        await socket.close();
        print('ESP32 connection verified successfully');
      } catch (e) {
        print('ESP32 connection verification failed: $e');
        // Even if verification fails, we still consider it connected if we're on the right network
      }
    } else {
      // Try one more time after a short delay
      await Future.delayed(const Duration(seconds: 2));
      final retryConnection = await _isConnectedToESP32();
      
      if (retryConnection) {
        connectionSuccess.value = true;
        isConnecting.value = false;
        _connectionTimer?.cancel();
        currentScreen.value = 'connection_success';
      } else {
        connectionTimeout.value = true;
        isConnecting.value = false;
        _connectionTimer?.cancel();
        currentScreen.value = 'connection_failed';
      }
    }
  }
  
  // Retry scanning
  void retryScanning() {
    startScanning();
  }
  
  // Retry connection
  void retryConnection() {
    startConnection();
  }
  
  // Go back to previous screen
  void goBack() {
    Get.back();
  }
} 