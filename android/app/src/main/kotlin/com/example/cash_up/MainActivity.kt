package com.example.cash_up

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var nfcBridge: NfcBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        nfcBridge = NfcBridge(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onPause() {
        super.onPause()
        nfcBridge?.stopReader()
    }
}
