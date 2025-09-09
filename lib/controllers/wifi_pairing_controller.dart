import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/wifi_connector.dart';
import 'package:flutter/services.dart'; // Added for MethodChannel

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
  static const String esp32IP = '192.168.4.2';
  
  // Enable WiFi automatically - non-blocking async version
  Future<void> _enableWiFiAsync() async {
    try {
      // Use Future.delayed to prevent blocking the UI thread
      await Future.delayed(const Duration(milliseconds: 100));
      
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
  
  // Check if WiFi is enabled - non-blocking async version
  Future<bool> _isWiFiEnabledAsync() async {
    try {
      // Use Future.delayed to prevent blocking the UI thread
      await Future.delayed(const Duration(milliseconds: 50));
      
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
      
      // Alternative: Try to ping ESP32 IP address (192.168.4.2)
      try {
        final result = await InternetAddress('192.168.4.2').reverse();
        print('ESP32 IP 192.168.4.2 reachable: ${result.host}');
        return true;
      } catch (e) {
        print('ESP32 IP 192.168.4.2 not reachable: $e');
      }
      
      // Additional check: Try to connect to ESP32 IP address (192.168.4.2)
      try {
        final socket = await Socket.connect('192.168.4.2', 80, timeout: const Duration(seconds: 2));
        await socket.close();
        print('ESP32 IP 192.168.4.2 connection successful');
        return true;
      } catch (e) {
        print('ESP32 IP 192.168.4.2 connection failed: $e');
      }
      
      print('Not connected to ESP32 network');
      return false;
    } catch (e) {
      print('Error checking ESP32 connection: $e');
      return false;
    }
  }

  // Enhanced method to check for Biostep+ device with immediate navigation - non-blocking async version
  Future<bool> _checkForBiostepDeviceAsync() async {
    try {
      print('=== Enhanced Biostep+ Device Check Started ===');
      
      // Use Future.delayed to prevent blocking the UI thread
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Check WiFi scan results for Biostep+ network FIRST (immediate detection)
      final canGetResults = await WiFiScan.instance.canGetScannedResults();
      if (canGetResults == CanGetScannedResults.yes) {
        final results = await WiFiScan.instance.getScannedResults();
        print('WiFi scan results count: ${results.length}');
        
        for (var network in results) {
          print('Found network: ${network.ssid} (${network.level} dBm)');
          if (network.ssid == 'bioSTEP+new') {
            print('✓ bioSTEP+new WiFi network found in scan results - IMMEDIATE DETECTION');
            print('🚀 NAVIGATING TO DEVICE FOUND SCREEN IMMEDIATELY');
            return true; // Return immediately without any connection checks
          }
        }
        print('✗ bioSTEP+new network not found in scan results');
      } else {
        print('✗ Cannot get WiFi scan results: $canGetResults');
      }
      
      // Only check connection if Biostep+ network is not found in scan results
      final isConnectedToESP32 = await _isConnectedToESP32();
      if (isConnectedToESP32) {
        print('✓ Already connected to ESP32 network - Biostep+ device found');
        return true;
      }
      
      print('=== Enhanced Biostep+ Device Check Completed - Device Not Found ===');
      return false;
    } catch (e) {
      print('✗ Error in enhanced Biostep+ device check: $e');
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
    
    // Disconnect from WiFi when controller is closed
    _disconnectFromWiFi();
    
    super.onClose();
  }
  
  // Disconnect from WiFi network and cleanup
  Future<void> _disconnectFromWiFi() async {
    try {
      print('🔗 Disconnecting from WiFi network...');
      await WifiConnector.disconnect();
      print('✅ WiFi disconnection completed');
    } catch (e) {
      print('❌ Error disconnecting from WiFi: $e');
    }
  }
  
  // Start scanning for WiFi devices
  Future<void> startScanning() async {
    try {
      isScanning.value = true;
      currentScreen.value = 'scanning';
      deviceFound.value = false;
      scanTimeout.value = false;
      
      // Request location permission (required for WiFi scanning) - non-blocking
      final permissionGranted = await _requestLocationPermissionAsync();
      if (!permissionGranted) {
        isScanning.value = false;
        return;
      }
      
      // Automatically turn on WiFi without opening settings - non-blocking
      await _enableWiFiAsync();
      
      // Verify WiFi is enabled - non-blocking
      final isWiFiEnabled = await _isWiFiEnabledAsync();
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
      
      // Enhanced immediate check for Biostep+ device - non-blocking
      final biostepDeviceFound = await _checkForBiostepDeviceAsync();
      if (biostepDeviceFound) {
        deviceFound.value = true;
        isScanning.value = false;
        _scanTimer?.cancel();
        currentScreen.value = 'device_found';
        print('🚀 IMMEDIATE NAVIGATION: bioSTEP+new device found immediately - navigating to device found screen');
        return;
      }
      
      // Start WiFi scanning with enhanced detection - non-blocking
      _performEnhancedWifiScanAsync();
      
    } catch (e) {
      print('Error in startScanning: $e');
      isScanning.value = false;
      currentScreen.value = 'device_not_found';
    }
  }
  
  // Perform enhanced WiFi scan with immediate Biostep+ detection - non-blocking async version
  void _performEnhancedWifiScanAsync() {
    // Use Future.microtask to prevent blocking the UI thread
    Future.microtask(() async {
      try {
        // Check if WiFi scanning is available
        final canGetScannedResults = await WiFiScan.instance.canGetScannedResults();
        
        if (canGetScannedResults == CanGetScannedResults.yes) {
          // Start initial scan
          await WiFiScan.instance.startScan();
          
          // Poll for results every 1 second for faster detection
          Timer.periodic(const Duration(seconds: 1), (timer) async {
            if (!this.isScanning.value || deviceFound.value) {
              timer.cancel();
              return;
            }
            
            try {
              // Use Future.delayed to prevent blocking the UI thread
              await Future.delayed(const Duration(milliseconds: 10));
              
              // Get current scan results FIRST for immediate SSID detection
              final results = await WiFiScan.instance.getScannedResults();
              if (results.isNotEmpty) {
                wifiNetworks.value = results;
                
                // Check if Biostep+ is in the available networks - IMMEDIATE DETECTION
                for (var network in results) {
                  if (network.ssid == 'bioSTEP+new') {
                    deviceFound.value = true;
                    this.isScanning.value = false;
                    _scanTimer?.cancel();
                    timer.cancel();
                    currentScreen.value = 'device_found';
                    print('🚀 ENHANCED SCAN IMMEDIATE NAVIGATION: bioSTEP+new SSID detected - navigating to device found screen immediately');
                    return; // Exit immediately without any connection checks
                  }
                }
              }
              
              // Start a new scan every 1 second to keep scanning fresh
              await WiFiScan.instance.startScan();
            } catch (e) {
              print('Enhanced WiFi scan polling error: $e');
            }
          });
        }
      } catch (e) {
        print('Enhanced WiFi scan error: $e');
      }
    });
  }

  
  // Navigate to device found screen
  void onDeviceFound() {
    print('🔄 Navigating to device found screen via onDeviceFound()');
    currentScreen.value = 'device_found';
  }
  
  // Force immediate navigation to device found screen when Biostep+ is detected
  void forceNavigateToDeviceFound() {
         print('🚀 FORCED NAVIGATION: bioSTEP+new device detected - navigating to device found screen');
    deviceFound.value = true;
    isScanning.value = false;
    _scanTimer?.cancel();
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
      
             // Additional verification: Check if we can reach the ESP32 IP (192.168.4.2)
       try {
         final socket = await Socket.connect('192.168.4.2', 80, timeout: const Duration(seconds: 5));
         await socket.close();
         print('ESP32 IP 192.168.4.2 connection verified successfully');
       } catch (e) {
         print('ESP32 IP 192.168.4.2 connection verification failed: $e');
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
    // Reset state
    deviceFound.value = false;
    scanTimeout.value = false;
    connectionSuccess.value = false;
    connectionTimeout.value = false;
    
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
  
  // Retry from connection failed - go back to scanning
  void retryFromConnectionFailed() {
    // Reset all connection-related states
    connectionSuccess.value = false;
    connectionTimeout.value = false;
    isConnecting.value = false;
    
    // Cancel any existing connection timer
    _connectionTimer?.cancel();
    
    // Start scanning again
    startScanning();
    // Ensure monitoring continues
    if (!isMonitoring.value) {
      startContinuousMonitoring();
    }
  }
  
  // Go back to previous screen
  void goBack() {
    Get.back();
  }
  
  // Start continuous WiFi monitoring every 1 second - non-blocking version
  void startContinuousMonitoring() {
    if (isMonitoring.value) return; // Prevent multiple monitoring timers
    
    isMonitoring.value = true;
    print('Starting continuous WiFi monitoring every 1 second');
    
    _monitoringTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Use Future.microtask to prevent blocking the UI thread
      Future.microtask(() async {
        try {
          // Use Future.delayed to prevent blocking the UI thread
          await Future.delayed(const Duration(milliseconds: 10));
          
          // Check WiFi scan results for Biostep+ network FIRST (immediate detection)
          final canGetResults = await WiFiScan.instance.canGetScannedResults();
          
          if (canGetResults == CanGetScannedResults.yes) {
            final results = await WiFiScan.instance.getScannedResults();
            
            if (results.isNotEmpty) {
              // Check if Biostep+ is in the available networks - IMMEDIATE DETECTION
              for (var network in results) {
                if (network.ssid == 'bioSTEP+new') {
                  print('WiFi monitoring: bioSTEP+new network found in scan results - IMMEDIATE DETECTION');
                  isConnectedToWiFi.value = true;
                  
                  // If we're currently scanning and find device, switch to device found immediately
                  if (currentScreen.value == 'scanning' && !deviceFound.value) {
                    deviceFound.value = true;
                    isScanning.value = false;
                    _scanTimer?.cancel();
                    currentScreen.value = 'device_found';
                    print('🚀 CONTINUOUS MONITORING IMMEDIATE NAVIGATION: bioSTEP+new SSID detected - immediately switching to device found');
                    return; // Exit immediately without any connection checks
                  }
                  break;
                }
              }
            }
          }
          
          // Only use enhanced device detection if Biostep+ network is not found in scan results
          final biostepDeviceFound = await _checkForBiostepDeviceAsync();
          isConnectedToWiFi.value = biostepDeviceFound;
          
          if (biostepDeviceFound) {
            print('WiFi monitoring: bioSTEP+new device detected via connection check');
            
            // If we're currently scanning and find device, switch to device found immediately
            if (currentScreen.value == 'scanning' && !deviceFound.value) {
              deviceFound.value = true;
              isScanning.value = false;
              _scanTimer?.cancel();
              currentScreen.value = 'device_found';
              print('🚀 CONTINUOUS MONITORING NAVIGATION: bioSTEP+new device detected - immediately switching to device found');
            }
          } else {
            print('WiFi monitoring: bioSTEP+new device not detected');
            
            // If we were connected but now lost connection, handle accordingly
            if (currentScreen.value == 'device_found' || currentScreen.value == 'connecting') {
              // Optionally restart scanning or show disconnection
              print('Connection lost during device found or connecting state');
            }
          }
          
          // Also perform a quick WiFi scan to check for available networks
          _performQuickWiFiCheckAsync();
          
        } catch (e) {
          print('Error in continuous WiFi monitoring: $e');
        }
      });
    });
  }
  
  // Stop continuous monitoring
  void stopContinuousMonitoring() {
    isMonitoring.value = false;
    _monitoringTimer?.cancel();
    print('Stopped continuous WiFi monitoring');
  }
  
  // Perform a quick WiFi check without full scanning - non-blocking async version
  void _performQuickWiFiCheckAsync() {
    // Use Future.microtask to prevent blocking the UI thread
    Future.microtask(() async {
      try {
        // Use Future.delayed to prevent blocking the UI thread
        await Future.delayed(const Duration(milliseconds: 10));
        
        // Check WiFi scan results for Biostep+ network FIRST (immediate detection)
        final canGetResults = await WiFiScan.instance.canGetScannedResults();
        
        if (canGetResults == CanGetScannedResults.yes) {
          final results = await WiFiScan.instance.getScannedResults();
          
          if (results.isNotEmpty) {
            wifiNetworks.value = results;
            
            // Check if Biostep+ is in the available networks - IMMEDIATE DETECTION
            for (var network in results) {
              if (network.ssid == 'bioSTEP+new') {
                print('Quick WiFi check: bioSTEP+new network found in scan results - IMMEDIATE DETECTION');
                
                // If scanning and Biostep+ is found, switch to device found immediately
                if (currentScreen.value == 'scanning' && !deviceFound.value) {
                  deviceFound.value = true;
                  isScanning.value = false;
                  _scanTimer?.cancel();
                  currentScreen.value = 'device_found';
                  print('🚀 QUICK CHECK IMMEDIATE NAVIGATION: bioSTEP+new SSID detected - immediately switching to device found');
                  return; // Exit immediately without any connection checks
                }
                break;
              }
            }
          }
        }
        
        // Only use enhanced device detection if Biostep+ network is not found in scan results
        final biostepDeviceFound = await _checkForBiostepDeviceAsync();
        
        if (biostepDeviceFound) {
          print('Quick WiFi check: bioSTEP+new device detected via connection check');
          
          // If scanning and Biostep+ is found, switch to device found immediately
          if (currentScreen.value == 'scanning' && !deviceFound.value) {
            deviceFound.value = true;
            isScanning.value = false;
            _scanTimer?.cancel();
            currentScreen.value = 'device_found';
            print('🚀 QUICK CHECK NAVIGATION: bioSTEP+new device detected - immediately switching to device found');
          }
        }
      } catch (e) {
        print('Error in quick WiFi check: $e');
      }
    });
  }

  // Connect to bioSTEP+new WiFi network when device icon is tapped - non-blocking version
  void connectToBiostepWiFi() {
    // Use Future.microtask to prevent blocking the UI thread
    Future.microtask(() async {
      try {
        print('🔗 Device icon tapped - immediately connecting to bioSTEP+new WiFi network...');
        
        // Use Future.delayed to prevent blocking the UI thread
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Check if bioSTEP+new network is still available
        final canGetResults = await WiFiScan.instance.canGetScannedResults();
        if (canGetResults == CanGetScannedResults.yes) {
          final results = await WiFiScan.instance.getScannedResults();
          
          bool networkFound = false;
          for (var network in results) {
            if (network.ssid == 'bioSTEP+new') {
              networkFound = true;
              print('✓ bioSTEP+new network found, initiating immediate connection...');
              break;
            }
          }
          
          if (!networkFound) {
            print('✗ bioSTEP+new network not found in scan results');
            Get.snackbar('Connection Failed', 'bioSTEP+new network not found. Please ensure the device is in pairing mode.');
            return;
          }
        }
        
        // Check and request necessary permissions first
        final permissionsGranted = await _checkAndRequestPermissions();
        if (!permissionsGranted) {
          print('❌ Required permissions not granted, aborting WiFi connection');
          return;
        }
        
        // Immediately navigate to connecting screen
        currentScreen.value = 'connecting';
        isConnecting.value = true;
        connectionSuccess.value = false;
        connectionTimeout.value = false;
        
        print('🚀 Navigating to connecting screen - starting WiFi connection process');
        
        // Start 25-second connection timer
        _connectionTimer = Timer(const Duration(seconds: 25), () {
          if (!connectionSuccess.value) {
            connectionTimeout.value = true;
            isConnecting.value = false;
            currentScreen.value = 'connection_failed';
          }
        });
        
        // Attempt to connect using WifiConnectorService (Android 10+)
        final success = await WifiConnector.connect(
          ssid: 'bioSTEP+new',
          password: 'biostim@123', // WPA2 password for the network
          bssid: null, // Optional: specify BSSID for precise targeting
          isHidden: false,
          timeout: const Duration(seconds: 25),
        );
        
        if (success) {
          print('✅ WiFi connection successful via WifiConnectorService');
          
          // Optional: Verify device reachability at 192.168.4.2
          final deviceReachable = await WifiConnector.verifyDeviceReachability('192.168.4.2');
          
          if (deviceReachable) {
            print('✅ Device reachability verified at 192.168.4.2');
            connectionSuccess.value = true;
            isConnecting.value = false;
            _connectionTimer?.cancel();
            currentScreen.value = 'connection_success';
          } else {
            print('⚠ Device not reachable at 192.168.4.2, but WiFi connection successful');
            // Still consider it successful since WiFi is connected
            connectionSuccess.value = true;
            isConnecting.value = false;
            _connectionTimer?.cancel();
            currentScreen.value = 'connection_success';
          }
        } else {
          print('❌ WiFi connection failed via WifiConnectorService');
          connectionTimeout.value = true;
          isConnecting.value = false;
          _connectionTimer?.cancel();
          currentScreen.value = 'connection_failed';
        }
        
      } catch (e) {
        print('Error connecting to bioSTEP+new WiFi: $e');
        connectionTimeout.value = true;
        isConnecting.value = false;
        currentScreen.value = 'connection_failed';
      }
    });
  }
  

  // Request location permission - non-blocking async version
  Future<bool> _requestLocationPermissionAsync() async {
    try {
      // Use Future.delayed to prevent blocking the UI thread
      await Future.delayed(const Duration(milliseconds: 50));
      
      var status = await Permission.location.request();
      if (status != PermissionStatus.granted) {
        Get.snackbar('Permission Required', 'Location permission is needed to scan WiFi networks');
        return false;
      }
      return true;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  // Check and request necessary permissions for WiFi connection
  Future<bool> _checkAndRequestPermissions() async {
    try {
      // Check location permission (required for WiFi operations on Android 6-12)
      var locationStatus = await Permission.location.status;
      if (locationStatus != PermissionStatus.granted) {
        locationStatus = await Permission.location.request();
        if (locationStatus != PermissionStatus.granted) {
          print('❌ Location permission denied - required for WiFi operations');
          Get.snackbar('Permission Required', 'Location permission is needed for WiFi connection. Please enable it in settings.');
          return false;
        }
      }
      
      // Check nearby WiFi devices permission (Android 13+)
      if (Platform.isAndroid) {
        final androidVersion = await _getAndroidVersion();
        if (androidVersion >= 33) { // API 33 = Android 13
          var nearbyWifiStatus = await Permission.nearbyWifiDevices.status;
          if (nearbyWifiStatus != PermissionStatus.granted) {
            nearbyWifiStatus = await Permission.nearbyWifiDevices.request();
            if (nearbyWifiStatus != PermissionStatus.granted) {
              print('❌ Nearby WiFi devices permission denied - required for Android 13+');
              Get.snackbar('Permission Required', 'Nearby WiFi devices permission is needed for WiFi connection. Please enable it in settings.');
              return false;
            }
          }
        }
      }
      
      print('✅ All required permissions granted');
      return true;
      
    } catch (e) {
      print('❌ Error checking permissions: $e');
      return false;
    }
  }
  
  // Get Android API level
  Future<int> _getAndroidVersion() async {
    try {
      const platform = MethodChannel('flutter/platform');
      final result = await platform.invokeMethod('getAndroidVersion');
      return result as int;
    } catch (e) {
      print('Error getting Android version: $e');
      return 0;
    }
  }
} 