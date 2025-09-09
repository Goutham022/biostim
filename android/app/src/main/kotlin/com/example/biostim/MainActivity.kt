package com.example.biostim

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register the WifiConnectorPlugin
        flutterEngine.plugins.add(WifiConnectorPlugin())
    }
}
