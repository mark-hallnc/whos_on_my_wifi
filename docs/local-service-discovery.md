# Local service discovery

NetworkScanner keeps the existing 40-worker TCP scan, then runs Android NSD for
four seconds. Address progress remains TCP-only; the service phase has a separate
status. The 1024-address cap still prevents automatic scans of larger subnets.

NsdDiscoveryChannel uses NsdManager, at most four concurrent type browsers with
one-second browsing slots, and one service resolution at a time. All eleven
requested TCP service families are queued. At most 128 unique services are queued.
Slow startup, resolution, multicast filtering or a busy LAN can cause a short scan
to miss services; this is not an exhaustive inventory. Dart has a 4.5-second
fallback deadline. No new TCP ports are probed.

Modern service-info callbacks and multiple addresses are used on API 34+ and
Android 13 with T SDK extension 7+. API 33+ browsing is bound to the captured
Android Network. Older Android browses all interfaces; Dart only accepts usable
IPv4 addresses in the captured subnet. Identical IPv4 subnets on multiple active
interfaces cannot be fully disambiguated on those older versions.

DNS hostname is available on API 36+ / T extension 17+. Older versions use the
actually advertised service instance as a name fallback, without reverse DNS.
IPv6 addresses are retained in service metadata but do not create IPv6-only rows.
TXT records are bounded to 24 keys, 64 characters per key and 256 per value;
binary values are decoded as UTF-8 with replacement and are not used as identity.

Older Android uses deprecated resolveService because it is the available API.
There is no cancellation API before T extension 7: one outstanding OS-owned
resolution may finish after cancellation; its result is ignored and no new
resolutions are scheduled. The next scan waits for that outstanding resolution
before starting another legacy resolution. Modern callbacks are unregistered.
All browsing is stopped, deadlines cleared and Wi-Fi multicast locks released on
completion, cancellation, backgrounding and disposal. Network identity/permission
is rechecked every 400 ms and before each Dart merge. Late session IDs are ignored.

A Wi-Fi MulticastLock is held only on older Android lacking automatic foreground
multicast management (before T extension 7). CHANGE_WIFI_MULTICAST_STATE supports
that lock. No location permission or additional runtime prompt was added.

Merging uses local IPv4, preserves existing identity/history/user data and stronger
hints, and deduplicates services by type, host, port and instance name. Advertised
ports are metadata, not proof of a successful TCP connection. Only printer
protocols infer hardware type; Cast/AirPlay/workstation remain capability hints.
Services add otherwise missed hosts. Technical attributes are expandable in
Device Details. The existing advertising/home layout is not modified.

References:
- https://developer.android.com/reference/android/net/nsd/NsdManager
- https://developer.android.com/reference/android/net/nsd/NsdServiceInfo
