/// A service advertised or observed on a local device.
class DiscoveredService {
  const DiscoveredService({
    required this.name,
    required this.type,
    required this.discoveryMethod,
    this.port,
    this.host,
    this.transport = 'TCP',
    this.hostname,
    this.addresses = const [],
    this.attributes = const {},
  });

  final String name;
  final String type;
  final String discoveryMethod;
  final int? port;
  final String? host;
  final String transport;
  final String? hostname;
  final List<String> addresses;
  final Map<String, String> attributes;

  String get identity =>
      '${type.toLowerCase()}|$host|$port|${name.toLowerCase()}';
  String get label => switch (type) {
    '_http._tcp.' => 'Web service',
    '_https._tcp.' => 'Secure web service',
    '_googlecast._tcp.' => 'Google Cast',
    '_airplay._tcp.' => 'AirPlay',
    '_raop._tcp.' => 'AirPlay audio',
    '_ipp._tcp.' || '_ipps._tcp.' || '_printer._tcp.' => 'Printer',
    '_smb._tcp.' => 'File sharing',
    '_workstation._tcp.' => 'Workstation',
    '_device-info._tcp.' => 'Device information',
    _ => 'Local service',
  };
}
