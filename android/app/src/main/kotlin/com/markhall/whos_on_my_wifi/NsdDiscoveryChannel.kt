package com.markhall.whos_on_my_wifi

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.nsd.NsdManager
import android.net.nsd.NsdServiceInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.ext.SdkExtensions
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayDeque
import java.util.concurrent.Executor

/** Foreground, bounded DNS-SD browsing. All mutable state is on the main looper. */
class NsdDiscoveryChannel(context: Context, messenger: BinaryMessenger) {
    private val app = context.applicationContext
    private val channel = MethodChannel(messenger, "whos_on_my_wifi/nsd")
    private val manager = app.getSystemService(Context.NSD_SERVICE) as NsdManager
    private val connectivity = app.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    private val handler = Handler(Looper.getMainLooper())
    private val executor = Executor { handler.post(it) }
    private var session: Session? = null
    // Legacy Android permits only one outstanding resolution and cannot cancel it.
    private var legacyBusy = false
    private val modern: Boolean get() = Build.VERSION.SDK_INT >= 34 ||
        (Build.VERSION.SDK_INT >= 33 && SdkExtensions.getExtensionVersion(33) >= 7)

    companion object {
        const val WINDOW_MS = 4000L
        const val BROWSE_MS = 1000L
        const val MAX_BROWSERS = 4
        const val MAX_SERVICES = 128
        val TYPES = setOf("_http._tcp.", "_https._tcp.", "_googlecast._tcp.",
            "_airplay._tcp.", "_raop._tcp.", "_ipp._tcp.", "_ipps._tcp.",
            "_printer._tcp.", "_smb._tcp.", "_workstation._tcp.", "_device-info._tcp.")
    }

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    if (session != null) {
                        result.error("busy", "NSD is already active.", null)
                    } else {
                        val network = connectivity.activeNetwork
                        if (network == null || network.toString() != call.argument<String>("networkId")) {
                            result.error("network_changed", "Network changed.", null)
                        } else {
                            val id = call.argument<Int>("id") ?: 0
                            val types = call.argument<List<String>>("types").orEmpty().filter { it in TYPES }.distinct()
                            val next = Session(id, network, types)
                            session = next
                            try {
                                next.start()
                                result.success(null)
                            } catch (_: SecurityException) {
                                next.stop()
                                result.error("permission_denied", "Local network access denied.", null)
                            } catch (_: Exception) {
                                next.stop()
                                result.error("nsd_unavailable", "NSD could not start.", null)
                            }
                        }
                    }
                }
                "stop" -> {
                    if (session?.id == call.argument<Int>("id")) session?.stop()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    fun stopForBackground() {
        session?.let {
            it.emit("cancelled", mapOf("message" to "App moved to the background. Scan cancelled."))
            it.stop()
        }
    }

    fun dispose() {
        session?.stop()
        channel.setMethodCallHandler(null)
    }

    @Suppress("DEPRECATION", "NewApi")
    private inner class Session(val id: Int, val network: Network, types: List<String>) {
        private var active = true
        private val pendingTypes = ArrayDeque(types)
        private val browsers = mutableSetOf<NsdManager.DiscoveryListener>()
        private val stopping = mutableSetOf<NsdManager.DiscoveryListener>()
        private val pendingServices = ArrayDeque<NsdServiceInfo>()
        private val seen = mutableSetOf<String>()
        private var resolving: NsdManager.ServiceInfoCallback? = null
        private var lock: WifiManager.MulticastLock? = null
        private val callbacks = mutableListOf<Runnable>()

        private fun later(delay: Long, action: () -> Unit) {
            val task = Runnable { if (active) action() }
            callbacks.add(task)
            handler.postDelayed(task, delay)
        }

        fun emit(method: String, data: Map<String, Any?> = emptyMap()) {
            if (active) channel.invokeMethod(method, data + ("id" to id))
        }

        private fun valid(): Boolean {
            if (!active) return false
            if (connectivity.activeNetwork != network) {
                emit("cancelled", mapOf("message" to "Network changed. Scan stopped."))
                stop()
                return false
            }
            return true
        }

        fun start() {
            // Older Android does not arrange Wi-Fi multicast reception for NSD.
            if (!modern && connectivity.getNetworkCapabilities(network)
                    ?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true) {
                val wifi = app.getSystemService(Context.WIFI_SERVICE) as WifiManager
                lock = wifi.createMulticastLock("whos_on_my_wifi:nsd").apply {
                    setReferenceCounted(false)
                    acquire()
                }
            }
            later(WINDOW_MS) { emit("done"); stop() }
            fillBrowsers()
        }

        private fun fillBrowsers() {
            if (!valid()) return
            while (browsers.size < MAX_BROWSERS && pendingTypes.isNotEmpty()) {
                val type = pendingTypes.removeFirst()
                val listener = object : NsdManager.DiscoveryListener {
                    override fun onDiscoveryStarted(serviceType: String) { handler.post {
                        if (!active) stopBrowser(this) else later(BROWSE_MS) { stopBrowser(this) }
                    } }
                    override fun onStartDiscoveryFailed(serviceType: String, errorCode: Int) { handler.post {
                        browsers.remove(this); stopping.remove(this)
                        emit("warning")
                        fillBrowsers()
                    } }
                    override fun onDiscoveryStopped(serviceType: String) { handler.post {
                        browsers.remove(this); stopping.remove(this)
                        fillBrowsers()
                    } }
                    override fun onStopDiscoveryFailed(serviceType: String, errorCode: Int) { handler.post {
                        // Do not start another browser if Android still holds this request.
                        stopping.remove(this)
                        if (active) later(100) { stopBrowser(this) }
                    } }
                    override fun onServiceLost(service: NsdServiceInfo) { }
                    override fun onServiceFound(service: NsdServiceInfo) { handler.post {
                        if (!valid()) return@post
                        // API 33+ identifies the network; reject other interfaces.
                        if (Build.VERSION.SDK_INT >= 33 && service.network != null && service.network != network) return@post
                        val key = "${service.serviceType}|${service.serviceName}"
                        if (seen.size < MAX_SERVICES && seen.add(key)) {
                            pendingServices.add(service)
                            resolveNext()
                        }
                    } }
                }
                browsers.add(listener)
                try {
                    if (Build.VERSION.SDK_INT >= 33) {
                        manager.discoverServices(type, NsdManager.PROTOCOL_DNS_SD, network, executor, listener)
                    } else {
                        manager.discoverServices(type, NsdManager.PROTOCOL_DNS_SD, listener)
                    }
                } catch (_: SecurityException) { permissionLost(); return }
                catch (_: Exception) { browsers.remove(listener); emit("warning") }
            }
        }

        private fun stopBrowser(listener: NsdManager.DiscoveryListener) {
            if (!browsers.contains(listener) || !stopping.add(listener)) return
            try { manager.stopServiceDiscovery(listener) }
            catch (_: Exception) { browsers.remove(listener); stopping.remove(listener); emit("warning") }
        }

        private fun resolveNext() {
            if (!valid() || resolving != null || legacyBusy || pendingServices.isEmpty()) return
            val service = pendingServices.removeFirst()
            if (modern) {
                val callback = object : NsdManager.ServiceInfoCallback {
                    override fun onServiceUpdated(info: NsdServiceInfo) {
                        if (valid()) publish(info)
                        unregister(this)
                    }
                    override fun onServiceLost() { unregister(this) }
                    override fun onServiceInfoCallbackRegistrationFailed(errorCode: Int) {
                        if (resolving === this) resolving = null
                        emit("warning"); resolveNext()
                    }
                    override fun onServiceInfoCallbackUnregistered() {
                        if (resolving === this) resolving = null
                        resolveNext()
                    }
                }
                resolving = callback
                try {
                    manager.registerServiceInfoCallback(service, executor, callback)
                    later(600) { if (resolving === callback) unregister(callback) }
                } catch (_: SecurityException) { permissionLost() }
                catch (_: Exception) { resolving = null; emit("warning"); resolveNext() }
            } else {
                legacyBusy = true
                val listener = object : NsdManager.ResolveListener {
                    override fun onResolveFailed(info: NsdServiceInfo, errorCode: Int) { handler.post {
                        legacyBusy = false; emit("warning"); session?.resolveNext()
                    } }
                    override fun onServiceResolved(info: NsdServiceInfo) { handler.post {
                        legacyBusy = false
                        if (valid()) publish(info)
                        session?.resolveNext()
                    } }
                }
                try { manager.resolveService(service, listener) }
                catch (_: SecurityException) { legacyBusy = false; permissionLost() }
                catch (_: Exception) { legacyBusy = false; emit("warning"); resolveNext() }
            }
        }

        private fun permissionLost() {
            emit("cancelled", mapOf("message" to "Local network permission unavailable. Scan stopped."))
            stop()
        }

        private fun unregister(callback: NsdManager.ServiceInfoCallback) {
            try { manager.unregisterServiceInfoCallback(callback) }
            catch (_: Exception) {
                if (resolving === callback) resolving = null
                if (active) resolveNext()
            }
        }

        private fun publish(info: NsdServiceInfo) {
            if (!valid()) return
            if (Build.VERSION.SDK_INT >= 33 && info.network != null && info.network != network) return
            val addresses = if (modern) info.hostAddresses.mapNotNull { it.hostAddress }
                else listOfNotNull(info.host?.hostAddress)
            val attributes = info.attributes.entries.take(24).associate {
                it.key.take(64) to String(it.value ?: byteArrayOf(), Charsets.UTF_8).take(256)
            }
            emit("service", mapOf("name" to info.serviceName, "type" to info.serviceType,
                "port" to info.port, "addresses" to addresses.take(16), "attributes" to attributes,
                "hostname" to if (Build.VERSION.SDK_INT >= 36 ||
                    (Build.VERSION.SDK_INT >= 33 && SdkExtensions.getExtensionVersion(33) >= 17)) info.hostname else null))
            // Older APIs do not expose the DNS hostname; never invoke reverse DNS.
        }

        fun stop() {
            if (!active) return
            active = false
            callbacks.forEach { handler.removeCallbacks(it) }
            callbacks.clear()
            pendingTypes.clear(); pendingServices.clear()
            browsers.toList().forEach { stopBrowser(it) }
            if (modern) resolving?.let { unregister(it) }
            resolving = null
            lock?.let { if (it.isHeld) it.release() }
            lock = null
            if (session === this) session = null
        }
    }
}
