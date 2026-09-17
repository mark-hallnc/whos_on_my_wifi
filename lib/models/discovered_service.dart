/// A service advertised or observed on a local device.
class DiscoveredService {
  const DiscoveredService({
    required this.name,
    required this.type,
    required this.discoveryMethod,
    this.port,
    this.host,
    this.transport = 'TCP',
  });

  final String name;
  final String type;
  final String discoveryMethod;
  final int? port;
  final String? host;
  final String transport;
}
