# Current network information

`NetworkInfoService` reads a Kotlin method channel; it never probes devices or
resolves hostnames. `CurrentNetworkController` owns session state independently
of `MockDeviceRepository`. Refresh happens at startup, on foreground return,
and before the scan placeholder or when a refresh button is tapped. Overlapping
refreshes use the newest request, so old results cannot replace newer data.

Android's `ConnectivityManager.activeNetwork`, `NetworkCapabilities`, and
`LinkProperties` supply the active transport, link addresses with their real
prefixes, default IPv4 gateway, DNS servers, and interface. The snapshot is
retried if the active network changes during the read. No network ID here is
a persistent saved-network identity.

`Ipv4Subnet` performs the subnet arithmetic in Dart. `/31` and `/32` have no
broadcast address. VPN/cellular addresses are not presented as broadcast LANs.

## Permissions and privacy

The manifest declares `INTERNET`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`,
and the future `ACCESS_LOCAL_NETWORK` permission. The runtime gate checks both
Android API **37+** and application target SDK **37+**. The existing SDK settings
are preserved (currently target 36); older configurations skip both the runtime
prompt and rationale. A permission string and numeric version guards avoid an
API 37 compile-time dependency.

Only an explicit Scan Network or Prepare/Retry access action can initiate the
permission flow. Connection metadata itself never triggers the prompt. The
in-app rationale precedes every runtime request; already-granted access skips
it. Denials keep the preview usable, with retry or app-settings paths. The
native requested-before flag survives restart. Returning from settings rereads
both network and permission state.

SSID retrieval uses `WifiInfo` transport metadata on API 29+, with the legacy
getter restricted to older OS versions. No location or nearby-Wi-Fi permission
is requested. Android can redact the SSID even with Wi-Fi state access; the UI
then says “SSID unavailable.”

## Limits and device verification

- This snapshot describes the app's active/default network, not every connected
  interface or a non-default Wi-Fi network. A VPN can hide the underlying LAN;
  its addresses and DNS are explicitly labeled as tunnel information.
- DNS, gateway, SSID, IPv6, and link properties can be absent. Missing values
  remain absent, with no `/24` assumption or fallback sample network.
- Internet validation reflects Android's capability flag, not an app probe.
- The eight device cards and their detail records remain fictional fixtures.
- On-device checks should cover Wi-Fi, cellular, airplane mode, VPN, IPv6-only
  Wi-Fi, foreground reconnect, and API 37 **with target 37** permission grant,
  denial, repeated denial, and settings revocation. Widget tests simulate these
  permission states; they do not replace API 37 system-dialog verification.

References:
- https://developer.android.com/privacy-and-security/local-network-permission
- https://developer.android.com/reference/android/net/LinkProperties
- https://developer.android.com/reference/android/net/wifi/WifiInfo
