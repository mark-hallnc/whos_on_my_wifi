package com.markhall.whos_on_my_wifi

import android.os.Handler
import android.os.Looper
import android.content.Context
import android.net.ConnectivityManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.Reader
import java.net.NetworkInterface
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import java.util.concurrent.ScheduledFuture

/** Best-effort read-only observations. No root, hidden APIs, ARP or route writes. */
class NeighborTableChannel(context: Context, messenger: BinaryMessenger) {
    private val connectivity = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    private val channel = MethodChannel(messenger, "whos_on_my_wifi/neighbors")
    private val main = Handler(Looper.getMainLooper())
    private val worker = Executors.newSingleThreadExecutor()
    private val watchdog = Executors.newSingleThreadScheduledExecutor()
    @Volatile private var active: Int? = null
    @Volatile private var process: Process? = null
    @Volatile private var disposed = false

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "cancel" -> {
                    if (call.argument<Int>("id") == active) stop()
                    result.success(null)
                }
                "read" -> {
                    val id = call.argument<Int>("id")
                    val ip = call.argument<String>("localIp")
                    if (disposed || active != null || id == null || ip == null) {
                        result.success(null)
                    } else {
                        active = id
                        worker.execute {
                            val data = try { read(id, ip) } catch (_: Exception) { null }
                            main.post {
                                result.success(if (!disposed && active == id) data else null)
                                if (active == id) active = null
                            }
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun bounded(reader: Reader): String = reader.use {
        val output = StringBuilder()
        val buffer = CharArray(4096)
        while (output.length < 262144) {
            val count = it.read(buffer, 0, minOf(buffer.size, 262144 - output.length))
            if (count < 0) break
            output.append(buffer, 0, count)
        }
        output.toString()
    }

    private fun read(id: Int, ip: String): Map<String, Any?>? {
        val network = connectivity.activeNetwork ?: return null
        val properties = connectivity.getLinkProperties(network) ?: return null
        if (properties.linkAddresses.none { it.address.hostAddress == ip }) return null
        val interfaceName = properties.interfaceName ?: return null
        val iface = NetworkInterface.getByName(interfaceName) ?: return null
        if (active != id) return null
        // Android 10+ usually denies /proc/net; failure is expected, not fatal.
        val arp = try { bounded(File("/proc/net/arp").reader()) } catch (_: Exception) { "" }
        var neighbors = ""
        if (active == id) {
            try {
                // Keep the dev column (some ip versions omit it with a dev filter).
                // Dart filters rows against the OS-selected interface. No shell.
                val child = ProcessBuilder("/system/bin/ip", "-4", "neigh", "show")
                    .redirectErrorStream(true).start()
                process = child
                var deadline: ScheduledFuture<*>? = null
                try {
                    deadline = watchdog.schedule({ child.destroy() }, 800, TimeUnit.MILLISECONDS)
                    if (active != id) child.destroy()
                    neighbors = bounded(child.inputStream.reader())
                } finally {
                    deadline?.cancel(false)
                    child.destroy()
                    child.inputStream.close()
                    child.errorStream.close()
                    child.outputStream.close()
                    process = null
                }
            } catch (_: Exception) { /* Missing ip binary or netlink denied by SELinux. */ }
        }
        val localMac = try {
            iface.hardwareAddress?.takeIf { it.size == 6 }?.joinToString(":") {
                "%02X".format(it.toInt() and 0xff)
            }
        } catch (_: Exception) { null }
        if (active != id || connectivity.activeNetwork != network ||
            NetworkInterface.getByName(iface.name)?.inetAddresses?.toList()
                ?.none { it.hostAddress == ip } != false) return null
        return mapOf("localIp" to ip, "interface" to iface.name, "arp" to arp,
            "neighbors" to neighbors, "localMac" to localMac)
    }

    fun stop() {
        active = null
        process?.destroy()
    }

    fun dispose() {
        disposed = true
        stop()
        channel.setMethodCallHandler(null)
        worker.shutdownNow()
        watchdog.shutdownNow()
    }
}
