import 'package:flutter/services.dart';

/// WiFi Connector Service for Android 10+ using WifiNetworkSpecifier
/// Provides session-based WiFi connections without saving networks
class WifiConnector {
  static const MethodChannel _channel = MethodChannel('wifi_connector');

  /// Connect to a WiFi network using WifiNetworkSpecifier (Android 10+)
  /// 
  /// [ssid] - Network SSID (e.g., "bioSTEP+new")
  /// [password] - Network password (null for open networks)
  /// [bssid] - Optional BSSID (MAC address) for precise targeting
  /// [isHidden] - Whether the network is hidden
  /// [timeout] - Connection timeout duration
  /// 
  /// Returns true if connection successful, false otherwise
  static Future<bool> connect({
    required String ssid,
    String? password,
    String? bssid,
    bool isHidden = false,
    Duration timeout = const Duration(seconds: 25),
  }) async {
    try {
      print('🔗 WifiConnector: Attempting to connect to $ssid');
      print('🔗 Target IP: 192.168.4.2');
      print('🔗 Security: ${password != null ? "WPA2" : "Open"}');
      
      final result = await _channel.invokeMethod('connect', {
        'ssid': ssid,
        'password': password,
        'bssid': bssid,
        'isHidden': isHidden,
        'timeoutMs': timeout.inMilliseconds,
      });
      
      final success = result['success'] as bool? ?? false;
      final message = result['message'] as String? ?? 'Unknown result';
      
      if (success) {
        print('✅ WifiConnector: Successfully connected to $ssid');
        print('✅ Network bound - traffic will route to 192.168.4.2');
      } else {
        print('❌ WifiConnector: Failed to connect to $ssid: $message');
      }
      
      return success;
    } catch (e) {
      print('❌ WifiConnector: Error connecting to $ssid: $e');
      return false;
    }
  }

  /// Disconnect from current WiFi network and unbind process
  /// This releases the session connection and restores normal internet routing
  static Future<void> disconnect() async {
    try {
      print('🔗 WifiConnector: Disconnecting and unbinding network...');
      
      await _channel.invokeMethod('disconnect');
      
      print('✅ WifiConnector: Successfully disconnected and unbound');
    } catch (e) {
      print('❌ WifiConnector: Error disconnecting: $e');
    }
  }

  /// Verify device reachability at specific IP address
  /// Useful for confirming the WiFi connection is working
  static Future<bool> verifyDeviceReachability(String ipAddress) async {
    try {
      print('🔍 WifiConnector: Verifying device reachability at $ipAddress');
      
      final result = await _channel.invokeMethod('verifyReachability', {
        'ipAddress': ipAddress,
        'timeoutMs': 5000, // 5 second timeout
      });
      
      final reachable = result['reachable'] as bool? ?? false;
      final message = result['message'] as String? ?? 'Unknown result';
      
      if (reachable) {
        print('✅ WifiConnector: Device at $ipAddress is reachable');
      } else {
        print('❌ WifiConnector: Device at $ipAddress not reachable: $message');
      }
      
      return reachable;
    } catch (e) {
      print('❌ WifiConnector: Error verifying reachability: $e');
      return false;
    }
  }

  /// Check if WiFi is enabled on the device
  static Future<bool> isWifiEnabled() async {
    try {
      final result = await _channel.invokeMethod('isWifiEnabled');
      return result['enabled'] as bool? ?? false;
    } catch (e) {
      print('❌ WifiConnector: Error checking WiFi status: $e');
      return false;
    }
  }

  /// Check if location services are enabled (required for WiFi operations on Android ≤12)
  static Future<bool> isLocationEnabled() async {
    try {
      final result = await _channel.invokeMethod('isLocationEnabled');
      return result['enabled'] as bool? ?? false;
    } catch (e) {
      print('❌ WifiConnector: Error checking location status: $e');
      return false;
    }
  }
}
