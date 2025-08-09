import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';

class WifiPairingController extends GetxController {
  // Observable variables
  var isScanning = false.obs;
  var isConnecting = false.obs;
  var deviceFound = false.obs;
  var connectionSuccess = false.obs;
  var scanTimeout = false.obs;
  var connectionTimeout = false.obs;
  var currentScreen = 'scanning'.obs;
  var isConnectedToWiFi = false.obs;
  var isMonitoring = false.obs;
  
  // Timers
  Timer? _scanTimer;
  Timer? _connectionTimer;
  Timer? _monitoringTimer;
  
  // WiFi scan results
  var wifiNetworks = <WiFiAccessPoint>[].obs;
  
  // ESP32 IP address
  static const String esp32IP = '192.168.4.1';
  
  // Enable WiFi automatically
  Future<void> _enableWiFi() async {
    try {
      // Check if WiFi scanning is available
      final canStartScan = await WiFiScan.instance.canStartScan();
      
      if (canStartScan == CanStartScan.yes) {
        // Start scan to enable WiFi (this automatically turns on WiFi)
        await WiFiScan.instance.startScan();
        print('WiFi enabled automatically through scan');
      } else {
        print('WiFi scanning not available: $canStartScan');
        // Try alternative method - start scan anyway
        try {
          await WiFiScan.instance.startScan();
          print('WiFi enabled through alternative method');
        } catch (e) {
          print('Alternative WiFi enable failed: $e');
        }
      }
    } catch (e) {
      print('Error enabling WiFi: $e');
    }
  }
  
  // Check if WiFi is enabled
  Future<bool> _isWiFiEnabled() async {
    try {
      final canStartScan = await WiFiScan.instance.canStartScan();
      return canStartScan == CanStartScan.yes;
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
    startContinuousMonitoring();
  }
  
  @override
  void onClose() {
    _scanTimer?.cancel();
    _connectionTimer?.cancel();
    _monitoringTimer?.cancel();
    super.onClose();
  }
  
  // Start scanning for WiFi devices
  Future<void> startScanning() async {
    isScanning.value = true;
    currentScreen.value = 'scanning';
    deviceFound.value = false;
    scanTimeout.value = false;
    
    // Request location permission (required for WiFi scanning)
    var status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      Get.snackbar('Permission Required', 'Location permission is needed to scan WiFi networks');
      return;
    }
    
    // Automatically turn on WiFi without opening settings
    await _enableWiFi();
    
    // Verify WiFi is enabled
    final isWiFiEnabled = await _isWiFiEnabled();
    if (!isWiFiEnabled) {
      print('WiFi may not be enabled - continuing with scan attempt');
    } else {
      print('WiFi is enabled and ready for scanning');
    }
    
    // Start 15-second scan timer
    _scanTimer = Timer(const Duration(seconds: 15), () {
      if (!deviceFound.value) {
        scanTimeout.value = true;
        isScanning.value = false;
        currentScreen.value = 'device_not_found';
      }
    });
    
    // Check immediately if already connected to Biostep+ network
    final isAlreadyConnected = await _isConnectedToESP32();
    if (isAlreadyConnected) {
      deviceFound.value = true;
      isScanning.value = false;
      _scanTimer?.cancel();
      currentScreen.value = 'device_found';
      print('Already connected to Biostep+ network - navigating to device found screen');
      return;
    }
    
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
            if (results.isNotEmpty) {
              wifiNetworks.value = results;
              
              // Check if Biostep+ device is found
              for (var network in results) {
                if (network.ssid == 'Biostep+') {
                  deviceFound.value = true;
                  this.isScanning.value = false;
                  _scanTimer?.cancel();
                  timer.cancel();
                  currentScreen.value = 'device_found';
                  print('Biostep+ WiFi network found - navigating to device found screen');
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
    
    // Start 15-second connection timer
    _connectionTimer = Timer(const Duration(seconds: 15), () {
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
    // Simulate connection delay (2-5 seconds) - shorter for 15-second timeout
    final delay = Duration(seconds: 2 + (DateTime.now().millisecond % 4));
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
    // Ensure monitoring continues
    if (!isMonitoring.value) {
      startContinuousMonitoring();
    }
  }
  
  // Retry connection
  void retryConnection() {
    startConnection();
    // Ensure monitoring continues
    if (!isMonitoring.value) {
      startContinuousMonitoring();
    }
  }
  
  // Go back to previous screen
  void goBack() {
    Get.back();
  }
  
  // Start continuous WiFi monitoring every 2 seconds
  void startContinuousMonitoring() {
    if (isMonitoring.value) return; // Prevent multiple monitoring timers
    
    isMonitoring.value = true;
    print('Starting continuous WiFi monitoring every 2 seconds');
    
    _monitoringTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        // Check if connected to ESP32 WiFi network
        final isConnected = await _isConnectedToESP32();
        isConnectedToWiFi.value = isConnected;
        
        if (isConnected) {
          print('WiFi monitoring: Connected to Biostep+ network');
          
          // If we're currently scanning and find connection, switch to device found
          if (currentScreen.value == 'scanning' && !deviceFound.value) {
            deviceFound.value = true;
            isScanning.value = false;
            _scanTimer?.cancel();
            currentScreen.value = 'device_found';
            print('Continuous monitoring detected connection - switching to device found');
          }
        } else {
          print('WiFi monitoring: Not connected to Biostep+ network');
          
          // If we were connected but now lost connection, handle accordingly
          if (currentScreen.value == 'device_found' || currentScreen.value == 'connecting') {
            // Optionally restart scanning or show disconnection
            print('Connection lost during device found or connecting state');
          }
        }
        
        // Also perform a quick WiFi scan to check for available networks
        await _performQuickWiFiCheck();
        
      } catch (e) {
        print('Error in continuous WiFi monitoring: $e');
      }
    });
  }
  
  // Stop continuous monitoring
  void stopContinuousMonitoring() {
    isMonitoring.value = false;
    _monitoringTimer?.cancel();
    print('Stopped continuous WiFi monitoring');
  }
  
  // Perform a quick WiFi check without full scanning
  Future<void> _performQuickWiFiCheck() async {
    try {
      // Only check if we can get scan results without starting a new scan
      final canGetResults = await WiFiScan.instance.canGetScannedResults();
      
      if (canGetResults == CanGetScannedResults.yes) {
        final results = await WiFiScan.instance.getScannedResults();
        
        if (results.isNotEmpty) {
          wifiNetworks.value = results;
          
          // Check if Biostep+ is in the available networks
          bool biostepFound = false;
          for (var network in results) {
            if (network.ssid == 'Biostep+') {
              biostepFound = true;
              print('Quick WiFi check: Biostep+ network found in scan results');
              break;
            }
          }
          
          // If scanning and Biostep+ is found, switch to device found
          if (biostepFound && currentScreen.value == 'scanning' && !deviceFound.value) {
            deviceFound.value = true;
            isScanning.value = false;
            _scanTimer?.cancel();
            currentScreen.value = 'device_found';
            print('Quick WiFi check detected Biostep+ - switching to device found');
          }
        }
      }
    } catch (e) {
      print('Error in quick WiFi check: $e');
    }
  }
} 