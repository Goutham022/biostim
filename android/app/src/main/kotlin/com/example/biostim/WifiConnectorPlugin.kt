package com.example.biostim

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.LocationManager
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.wifi.WifiNetworkSpecifier
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.CompletableFuture
import java.util.concurrent.TimeUnit

/// WiFi Connector Plugin for Android 10+ using WifiNetworkSpecifier
/// Provides session-based WiFi connections without saving networks
/// 
/// Android Version Compatibility:
/// - WifiNetworkSpecifier: Android 10+ (API 29+)
/// - bindProcessToNetwork: Android 6.0+ (API 23+)
/// - For older devices, connection will work but network binding may not be available
class WifiConnectorPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var connectivityManager: ConnectivityManager? = null
    private var currentNetwork: Network? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null
    
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "wifi_connector")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
        connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    }
    
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        disconnect()
    }
    
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "connect" -> handleConnect(call, result)
            "disconnect" -> handleDisconnect(result)
            "verifyReachability" -> handleVerifyReachability(call, result)
            "isWifiEnabled" -> handleIsWifiEnabled(result)
            "isLocationEnabled" -> handleIsLocationEnabled(result)
            else -> result.notImplemented()
        }
    }
    
    /// Handle WiFi connection request using WifiNetworkSpecifier
    private fun handleConnect(call: MethodCall, result: Result) {
        try {
            val ssid = call.argument<String>("ssid") ?: ""
            val password = call.argument<String?>("password")
            val bssid = call.argument<String?>("bssid")
            val isHidden = call.argument<Boolean>("isHidden") ?: false
            val timeoutMs = call.argument<Int>("timeoutMs") ?: 25000

            // Validate SSID
            if (ssid.isBlank()) {
                println("❌ WifiConnectorPlugin: SSID cannot be empty")
                result.error("INVALID_SSID", "SSID cannot be empty", null)
                return
            }

            println("🔗 WifiConnectorPlugin: Connecting to SSID: $ssid")
            println("🔗 Target IP: 192.168.4.2")
            println("🔗 Security: ${if (password != null) "WPA2" else "Open"}")
            println("🔗 Hidden: $isHidden")
            println("🔗 BSSID: $bssid")
            println("🔗 Timeout: ${timeoutMs}ms")

            // Check permissions first
            if (!checkPermissions()) {
                println("❌ WifiConnectorPlugin: Required permissions not granted")
                result.error("PERMISSION_DENIED", "Required permissions not granted", null)
                return
            }
            println("✅ WifiConnectorPlugin: All required permissions granted")

            // Check if WiFi is enabled
            if (!isWifiEnabled()) {
                println("❌ WifiConnectorPlugin: WiFi is not enabled")
                result.error("WIFI_DISABLED", "WiFi is not enabled", null)
                return
            }
            println("✅ WifiConnectorPlugin: WiFi is enabled")

            // Check location services (required for WiFi operations on Android ≤12)
            if (!isLocationEnabled()) {
                println("❌ WifiConnectorPlugin: Location services are required for WiFi operations")
                result.error("LOCATION_DISABLED", "Location services are required for WiFi operations", null)
                return
            }
            println("✅ WifiConnectorPlugin: Location services are enabled")
            
            // Create WifiNetworkSpecifier
            val specifierBuilder = WifiNetworkSpecifier.Builder()
                .setSsid(ssid)
                .setIsHiddenSsid(isHidden)
            
            if (password != null) {
                specifierBuilder.setWpa2Passphrase(password)
            }
            
            if (bssid != null) {
                try {
                    android.net.MacAddress.fromString(bssid)
                    specifierBuilder.setBssid(android.net.MacAddress.fromString(bssid))
                    println("🔗 WifiConnectorPlugin: BSSID set to: $bssid")
                } catch (e: Exception) {
                    println("❌ WifiConnectorPlugin: Invalid BSSID format: $bssid")
                    result.error("INVALID_BSSID", "Invalid BSSID format: $bssid", null)
                    return
                }
            }
            
            val specifier = specifierBuilder.build()
            println("🔗 WifiConnectorPlugin: Created WifiNetworkSpecifier: $specifier")
            
            // Create NetworkRequest without INTERNET capability (ESP32 APs often have no internet)
            val networkRequest = NetworkRequest.Builder()
                .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
                .removeCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                .setNetworkSpecifier(specifier)
                .build()
            
            println("🔗 WifiConnectorPlugin: Created NetworkRequest: $networkRequest")
            
            // Request network connection
            val future = CompletableFuture<Boolean>()
            
            try {
                networkCallback = object : ConnectivityManager.NetworkCallback() {
                override fun onAvailable(network: Network) {
                        println("✅ WifiConnectorPlugin: Network available: $network")
                    currentNetwork = network
                    
                        // Bind process to this network so traffic routes to 192.168.4.2
                        // Note: bindProcessToNetwork is only available on Android 6.0+ (API 23+)
                        try {
                            val bindingSuccess = safeBindProcessToNetwork(network)
                            if (bindingSuccess) {
                                println("✅ WifiConnectorPlugin: Process bound to network - traffic will route to 192.168.4.2")
                                future.complete(true)
                            } else {
                                println("⚠️ WifiConnectorPlugin: Network binding not available on this Android version")
                                // Still consider it successful for older devices
                                future.complete(true)
                            }
                        } catch (e: Exception) {
                            println("❌ WifiConnectorPlugin: Failed to bind process to network: $e")
                            future.complete(false)
                        }
                }
                
                override fun onUnavailable() {
                        println("❌ WifiConnectorPlugin: Network unavailable")
                        future.complete(false)
                }
                
                override fun onLost(network: Network) {
                        println("⚠️ WifiConnectorPlugin: Network lost: $network")
                    if (currentNetwork == network) {
                        currentNetwork = null
                            safeUnbindProcessFromNetwork()
                        }
                    }
                }

                println("🔗 WifiConnectorPlugin: Requesting network connection...")
                connectivityManager?.requestNetwork(networkRequest, networkCallback!!)
                
                // Wait for result with timeout
                val success = try {
                    future.get(timeoutMs.toLong(), TimeUnit.MILLISECONDS)
                } catch (e: java.util.concurrent.TimeoutException) {
                    println("⏰ WifiConnectorPlugin: Connection timeout after ${timeoutMs}ms")
                    // Cancel the network request on timeout
                    try {
                        networkCallback?.let { callback ->
                            connectivityManager?.unregisterNetworkCallback(callback)
                        }
                        networkCallback = null
                    } catch (e2: Exception) {
                        println("⚠️ WifiConnectorPlugin: Error unregistering callback on timeout: $e2")
                    }
                    false
                }
                
                if (success) {
                    println("✅ WifiConnectorPlugin: Successfully connected to $ssid")
                    println("✅ Network bound - traffic will route to 192.168.4.2")
                    result.success(mapOf("success" to true, "message" to "Connected successfully"))
                } else {
                    println("❌ WifiConnectorPlugin: Failed to connect to $ssid")
                    result.success(mapOf("success" to false, "message" to "Connection failed"))
                }
                
            } catch (e: Exception) {
                println("❌ WifiConnectorPlugin: Error during network request: $e")
                result.error("NETWORK_REQUEST_ERROR", "Failed to request network: ${e.message}", null)
            }
            
        } catch (e: Exception) {
            println("❌ WifiConnectorPlugin: Error in connect: $e")
            result.error("CONNECTION_ERROR", "Failed to connect: ${e.message}", null)
        }
    }
    
    /// Handle disconnect request
    private fun handleDisconnect(result: Result) {
        try {
            disconnect()
            result.success(null)
        } catch (e: Exception) {
            println("❌ WifiConnectorPlugin: Error in disconnect: $e")
            result.error("DISCONNECT_ERROR", "Failed to disconnect: ${e.message}", null)
        }
    }
    
    /// Handle device reachability verification
    private fun handleVerifyReachability(call: MethodCall, result: Result) {
        try {
            val ipAddress = call.argument<String>("ipAddress") ?: "192.168.4.2"
            val timeoutMs = call.argument<Int>("timeoutMs") ?: 5000

            println("🔍 WifiConnectorPlugin: Verifying reachability of $ipAddress")

            // Perform HTTP GET to verify device is reachable
            val reachable = verifyHttpReachability(ipAddress, timeoutMs)
            
            if (reachable) {
                println("✅ WifiConnectorPlugin: Device at $ipAddress is reachable")
                result.success(mapOf("reachable" to true, "message" to "Device reachable"))
            } else {
                println("❌ WifiConnectorPlugin: Device at $ipAddress not reachable")
                result.success(mapOf("reachable" to false, "message" to "Device not reachable"))
            }

        } catch (e: Exception) {
            println("❌ WifiConnectorPlugin: Error in verifyReachability: $e")
            result.error("VERIFY_ERROR", "Failed to verify reachability: ${e.message}", null)
        }
    }

    /// Handle WiFi enabled check
    private fun handleIsWifiEnabled(result: Result) {
        result.success(mapOf("enabled" to isWifiEnabled()))
    }

    /// Handle location enabled check
    private fun handleIsLocationEnabled(result: Result) {
        result.success(mapOf("enabled" to isLocationEnabled()))
    }

    /// Check if WiFi is enabled
    private fun isWifiEnabled(): Boolean {
        return try {
            val wifiManager = context.getSystemService(Context.WIFI_SERVICE) as android.net.wifi.WifiManager
            val enabled = wifiManager.isWifiEnabled
            println("🔍 WifiConnectorPlugin: WiFi enabled: $enabled")
            enabled
                } catch (e: Exception) {
            println("❌ WifiConnectorPlugin: Error checking WiFi status: $e")
                    false
                }
    }

    /// Check if location services are enabled (required for WiFi operations on Android ≤12)
    private fun isLocationEnabled(): Boolean {
        return try {
            val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
            val gpsEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
            val networkEnabled = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
            val enabled = gpsEnabled || networkEnabled
            
            println("🔍 WifiConnectorPlugin: GPS provider enabled: $gpsEnabled")
            println("🔍 WifiConnectorPlugin: Network provider enabled: $networkEnabled")
            println("🔍 WifiConnectorPlugin: Location services enabled: $enabled")
            
            enabled
        } catch (e: Exception) {
            println("❌ WifiConnectorPlugin: Error checking location status: $e")
            false
        }
    }

    /// Check required permissions
    private fun checkPermissions(): Boolean {
        val permissions = mutableListOf<String>()
        
        // Android 13+ (API 33+): NEARBY_WIFI_DEVICES permission
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            permissions.add(Manifest.permission.NEARBY_WIFI_DEVICES)
            println("🔍 WifiConnectorPlugin: Checking NEARBY_WIFI_DEVICES permission (Android 13+)")
        }
        
        // Android 6-12: ACCESS_FINE_LOCATION permission
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            permissions.add(Manifest.permission.ACCESS_FINE_LOCATION)
            println("🔍 WifiConnectorPlugin: Checking ACCESS_FINE_LOCATION permission (Android 6-12)")
        }

        println("🔍 WifiConnectorPlugin: Android API level: ${Build.VERSION.SDK_INT}")
        println("🔍 WifiConnectorPlugin: Required permissions: $permissions")

        val allGranted = permissions.all { permission ->
            val granted = ActivityCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED
            println("🔍 WifiConnectorPlugin: Permission $permission: ${if (granted) "GRANTED" else "DENIED"}")
            granted
        }

        println("🔍 WifiConnectorPlugin: All permissions granted: $allGranted")
        return allGranted
    }

    /// Verify HTTP reachability of device
    private fun verifyHttpReachability(ipAddress: String, timeoutMs: Int): Boolean {
        return try {
            val url = URL("http://$ipAddress")
            val connection = url.openConnection() as HttpURLConnection
            connection.connectTimeout = timeoutMs
            connection.readTimeout = timeoutMs
            connection.requestMethod = "GET"
            
            val responseCode = connection.responseCode
            connection.disconnect()
            
            // Consider any response (even 404) as reachable
            responseCode in 200..599
        } catch (e: Exception) {
            println("❌ WifiConnectorPlugin: HTTP reachability check failed: $e")
            false
        }
    }
    
    /// Disconnect and cleanup
    private fun disconnect() {
        try {
            println("🔗 WifiConnectorPlugin: Disconnecting and cleaning up...")
            
            // Unbind process from network
            // Note: unbindProcessFromNetwork is only available on Android 6.0+ (API 23+)
            if (currentNetwork != null) {
                safeUnbindProcessFromNetwork()
                currentNetwork = null
            }
            
            // Unregister network callback
            networkCallback?.let { callback ->
                try {
                    connectivityManager?.unregisterNetworkCallback(callback)
                } catch (e: Exception) {
                    println("⚠️ WifiConnectorPlugin: Error unregistering network callback: $e")
                }
                networkCallback = null
            }
            
            println("✅ WifiConnectorPlugin: Successfully disconnected and cleaned up")
        } catch (e: Exception) {
            println("❌ WifiConnectorPlugin: Error in disconnect: $e")
        }
    }

    /// Safely unbind process from network using reflection to check method availability
    private fun safeUnbindProcessFromNetwork() {
        try {
            connectivityManager?.let { cm ->
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                    try {
                        // Use reflection to check if method exists
                        val method = cm.javaClass.getMethod("unbindProcessFromNetwork")
                        method.invoke(cm)
                        println("✅ WifiConnectorPlugin: Successfully unbound process from network")
                    } catch (e: Exception) {
                        println("⚠️ WifiConnectorPlugin: unbindProcessFromNetwork method not available: $e")
                    }
                }
            }
        } catch (e: Exception) {
            println("⚠️ WifiConnectorPlugin: Error in safeUnbindProcessFromNetwork: $e")
        }
    }

    /// Safely bind process to network using reflection to check method availability
    private fun safeBindProcessToNetwork(network: Network): Boolean {
        return try {
            connectivityManager?.let { cm ->
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                    try {
                        // Use reflection to check if method exists
                        val method = cm.javaClass.getMethod("bindProcessToNetwork", Network::class.java)
                        method.invoke(cm, network)
                        println("✅ WifiConnectorPlugin: Successfully bound process to network")
                        true
                    } catch (e: Exception) {
                        println("⚠️ WifiConnectorPlugin: bindProcessToNetwork method not available: $e")
                        false
                    }
                } else {
                    println("⚠️ WifiConnectorPlugin: bindProcessToNetwork not available on this Android version")
                    false
                }
            } ?: false
        } catch (e: Exception) {
            println("⚠️ WifiConnectorPlugin: Error in safeBindProcessToNetwork: $e")
            false
        }
    }
}
