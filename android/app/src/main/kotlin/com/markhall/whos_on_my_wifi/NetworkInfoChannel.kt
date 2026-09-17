package com.markhall.whos_on_my_wifi

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.Uri
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.net.Inet4Address
import java.net.Inet6Address

/** OS metadata only: no sockets, probing, DNS resolution, or Wi-Fi scans. */
class NetworkInfoChannel(private val activity: Activity, messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, "whos_on_my_wifi/network")
    private val connectivity = activity.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    private val preferences = activity.getSharedPreferences("network_permissions", Context.MODE_PRIVATE)
    private var pendingPermission: MethodChannel.Result? = null

    init {
        channel.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "getNetworkInfo" -> result.success(readNetwork())
                    "getLocalNetworkPermission" -> result.success(permissionStatus())
                    "requestLocalNetworkPermission" -> requestPermission(result)
                    "openAppSettings" -> {
                        activity.startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                            Uri.parse("package:${activity.packageName}")))
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            } catch (_: SecurityException) {
                result.error("permission_denied", "Android restricted access to network information.", null)
            } catch (_: Exception) {
                result.error("network_unavailable", "Could not read Android network information.", null)
            }
        }
    }

    private fun readNetwork(): Map<String, Any?> {
        // This is an on-demand snapshot, refreshed on resume and user actions.
        // Retry if the default network changes while its properties are read.
        repeat(2) {
            val network = connectivity.activeNetwork
                ?: return mapOf("connectionType" to "none", "networkId" to "none")
            val capabilities = connectivity.getNetworkCapabilities(network)
            val properties = connectivity.getLinkProperties(network)
            if (network != connectivity.activeNetwork) return@repeat
            if (capabilities == null) return mapOf("connectionType" to "unknown",
                "notice" to "Network connection is changing. Please refresh.")

            val wifi = capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
            val vpn = capabilities.hasTransport(NetworkCapabilities.TRANSPORT_VPN)
            val type = when {
                vpn -> "vpn"
                wifi -> "wifi"
                capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> "ethernet"
                capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "cellular"
                else -> "other"
            }
            // Keep addresses, routes and DNS from ONE network. A VPN's link
            // properties describe its tunnel; do not invent its underlying LAN.
            val addresses = properties?.linkAddresses.orEmpty().filter {
                !it.address.isLoopbackAddress && !it.address.isAnyLocalAddress
            }
            val ipv4 = addresses.firstOrNull { it.address is Inet4Address }
            val gateway = properties?.routes?.firstOrNull {
                it.isDefaultRoute && it.gateway is Inet4Address &&
                    it.gateway?.isAnyLocalAddress == false
            }?.gateway?.hostAddress
            return mapOf(
                "networkId" to network.toString(),
                "connectionType" to type,
                "isWifiConnected" to wifi,
                "ssid" to if (wifi && !vpn) readSsid(capabilities) else null,
                "ipv4Address" to ipv4?.address?.hostAddress,
                "ipv4PrefixLength" to ipv4?.prefixLength,
                "ipv6Addresses" to addresses.filter { it.address is Inet6Address }.map {
                    mapOf("address" to it.address.hostAddress, "prefixLength" to it.prefixLength)
                },
                "gateway" to gateway,
                "dnsServers" to properties?.dnsServers.orEmpty().mapNotNull { it.hostAddress },
                "interfaceName" to properties?.interfaceName,
                "internetValidated" to capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED),
                "notice" to when {
                    vpn -> "Addresses and DNS describe the VPN tunnel. The underlying Wi-Fi network may be hidden."
                    properties == null -> "Android has not provided this connection's address details. Please refresh."
                    else -> null
                }
            )
        }
        return mapOf("connectionType" to "unknown",
            "notice" to "Network connection is changing. Please refresh.")
    }

    @Suppress("DEPRECATION")
    private fun readSsid(capabilities: NetworkCapabilities): String? {
        return try {
            // Modern transport metadata first. No location permission requested.
            // The legacy getter is used ONLY before transportInfo existed.
            val info = if (Build.VERSION.SDK_INT >= 29) {
                capabilities.transportInfo as? WifiInfo
            } else {
                val wifi = activity.applicationContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager
                wifi?.connectionInfo
            }
            info?.ssid?.removeSurrounding("\"")?.takeIf {
                it.isNotBlank() && it != WifiManager.UNKNOWN_SSID
            }
        } catch (_: SecurityException) {
            null // SSID privacy must not hide otherwise available link metadata.
        }
    }

    private fun permissionRequired() = Build.VERSION.SDK_INT >= 37 &&
        activity.applicationInfo.targetSdkVersion >= 37

    private fun permissionStatus(): String {
        if (!permissionRequired()) return "notRequired"
        if (activity.checkSelfPermission(LOCAL_NETWORK_PERMISSION) == PackageManager.PERMISSION_GRANTED) {
            return "granted"
        }
        if (!preferences.getBoolean("requested", false)) return "notRequested"
        return if (activity.shouldShowRequestPermissionRationale(LOCAL_NETWORK_PERMISSION)) {
            "denied"
        } else {
            "permanentlyDenied"
        }
    }

    private fun requestPermission(result: MethodChannel.Result) {
        val status = permissionStatus()
        if (status != "notRequested" && status != "denied") {
            result.success(status)
            return
        }
        if (pendingPermission != null) {
            result.error("request_in_progress", "A permission request is already open.", null)
            return
        }
        // Flutter has presented the rationale and received explicit agreement.
        pendingPermission = result
        preferences.edit().putBoolean("requested", true).apply()
        try {
            activity.requestPermissions(arrayOf(LOCAL_NETWORK_PERMISSION), PERMISSION_REQUEST)
        } catch (error: Exception) {
            pendingPermission = null
            throw error
        }
    }

    fun onRequestPermissionsResult(requestCode: Int) {
        if (requestCode != PERMISSION_REQUEST) return
        pendingPermission?.success(permissionStatus())
        pendingPermission = null
    }

    fun dispose() {
        pendingPermission?.error("activity_closed", "Permission request interrupted.", null)
        pendingPermission = null
        channel.setMethodCallHandler(null)
    }

    companion object {
        // String/numeric guards compile with older SDKs; no API 37 symbols used.
        private const val LOCAL_NETWORK_PERMISSION = "android.permission.ACCESS_LOCAL_NETWORK"
        private const val PERMISSION_REQUEST = 7037
    }
}
