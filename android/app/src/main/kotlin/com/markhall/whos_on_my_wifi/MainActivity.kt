package com.markhall.whos_on_my_wifi

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var nsdChannel: NsdDiscoveryChannel? = null
    private var networkInfoChannel: NetworkInfoChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        networkInfoChannel = NetworkInfoChannel(this, flutterEngine.dartExecutor.binaryMessenger)
        nsdChannel = NsdDiscoveryChannel(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        networkInfoChannel?.onRequestPermissionsResult(requestCode)
    }

    override fun onStop() {
        nsdChannel?.stopForBackground()
        super.onStop()
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        nsdChannel?.dispose()
        nsdChannel = null
        networkInfoChannel?.dispose()
        networkInfoChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
