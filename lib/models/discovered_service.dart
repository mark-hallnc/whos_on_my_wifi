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
      '${type.toLowerCase()}|$host|$port|${name.toLowerCase()}'
      '${type == 'ws-discovery' ? '|${attributes['endpoint'] ?? ''}' : ''}';
  String get label => switch (type
      .toLowerCase()
      .replaceFirst(RegExp(r'\.local\.?$'), '')
      .replaceFirst(RegExp(r'\.+$'), '')) {
    '_http._tcp' => 'Web Interface',
    '_https._tcp' => 'Secure Web Interface',
    '_googlecast._tcp' => 'Google Cast',
    '_airplay._tcp' => 'AirPlay',
    '_raop._tcp' => 'AirPlay Audio',
    '_ipp._tcp' || '_printer._tcp' => 'Printer',
    '_ipps._tcp' => 'Secure Printer',
    '_smb._tcp' => 'File Sharing',
    '_workstation._tcp' => 'Workstation',
    '_device-info._tcp' => 'Device Information',
    'nbns:node-status' => 'NetBIOS Name',
    'llmnr:ptr' => 'Local Hostname',
    'ws-discovery' => 'Web Services Discovery',
    _ => _upnpLabel,
  };

  String get _upnpLabel {
    final parts = type.toLowerCase().split(':');
    if (parts.length >= 4 &&
        parts[0] == 'urn' &&
        parts[1] == 'schemas-upnp-org' &&
        parts[2] == 'service') {
      return switch (parts[3]) {
        'avtransport' => 'Media Playback',
        'renderingcontrol' => 'Media Controls',
        'contentdirectory' => 'Media Library',
        'wanipconnection' || 'wanpppconnection' => 'Internet Gateway',
        _ => name,
      };
    }
    return 'Local Service';
  }
}
