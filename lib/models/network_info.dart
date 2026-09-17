enum NetworkIsolationStatus { notChecked, suspected, notDetected }

class NetworkInfo {
  const NetworkInfo({
    required this.id,
    this.name,
    this.localIpAddress,
    this.gatewayAddress,
    this.subnet,
    this.isolationStatus = NetworkIsolationStatus.notChecked,
  });

  final String id;
  final String? name;
  final String? localIpAddress;
  final String? gatewayAddress;
  final String? subnet;
  final NetworkIsolationStatus isolationStatus;
}
