enum NetworkIsolationStatus { notChecked, suspected, notDetected }

enum NetworkConnectionType {
  wifi,
  ethernet,
  cellular,
  vpn,
  other,
  none,
  unknown,
}

class NetworkAddress {
  const NetworkAddress({required this.address, required this.prefixLength});
  final String address;
  final int prefixLength;
  String get cidr => '$address/$prefixLength';
}

class NetworkInfo {
  const NetworkInfo({
    required this.id,
    this.name,
    this.localIpAddress,
    this.gatewayAddress,
    this.subnet,
    this.connectionType = NetworkConnectionType.unknown,
    this.isWifiConnected = false,
    this.ipv6Addresses = const [],
    this.subnetMask,
    this.ipv4PrefixLength,
    this.networkAddress,
    this.broadcastAddress,
    this.dnsServers = const [],
    this.interfaceName,
    this.internetValidated = false,
    this.notice,
    this.isolationStatus = NetworkIsolationStatus.notChecked,
  });

  final String id;
  final String? name;
  final String? localIpAddress;
  final String? gatewayAddress;
  final String? subnet;
  final NetworkConnectionType connectionType;

  /// Whether Android reports Wi-Fi transport for the active network.
  /// With a VPN this can describe the underlying transport, not the tunnel.
  final bool isWifiConnected;
  final List<NetworkAddress> ipv6Addresses;
  final String? subnetMask;
  final int? ipv4PrefixLength;
  final String? networkAddress;
  final String? broadcastAddress;
  final List<String> dnsServers;
  final String? interfaceName;
  final bool internetValidated;
  final String? notice;
  final NetworkIsolationStatus isolationStatus;
}
