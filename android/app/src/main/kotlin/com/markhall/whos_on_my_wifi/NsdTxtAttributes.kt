package com.markhall.whos_on_my_wifi

/**
 * Android's TXT map may have an EntrySet whose toArray() is unsupported.
 * Keep this an explicit iterator copy: entries.take/toList and collection-copy
 * constructors can call toArray(), even for an otherwise valid framework map.
 * The supplier also guards exceptions from NsdServiceInfo.getAttributes().
 */
internal fun safeNsdAttributes(readAttributes: () -> Map<String, ByteArray?>): Map<String, String> {
    return try {
        val attributes = LinkedHashMap<String, String>()
        val iterator = readAttributes().entries.iterator()
        var count = 0
        while (count < 24 && iterator.hasNext()) {
            val entry = iterator.next()
            count++
            // A Java/framework map can contain null despite its declared key type.
            val key: String? = entry.key
            if (key == null) continue
            val value = try {
                String(entry.value ?: byteArrayOf(), Charsets.UTF_8).take(256)
            } catch (_: Exception) {
                ""
            }
            attributes[key.take(64)] = value
        }
        attributes
    } catch (_: Exception) {
        // TXT is optional: failure to retrieve or iterate it must not drop the service.
        emptyMap()
    }
}
