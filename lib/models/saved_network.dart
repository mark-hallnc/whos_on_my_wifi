import 'network_info.dart';

class SavedNetwork {
  const SavedNetwork({
    required this.id,
    required this.key,
    required this.network,
    required this.firstSeen,
    required this.lastSeen,
    required this.deviceCount,
    required this.scanCount,
    this.lastScanned,
  });
  final int id;
  final String key;
  final NetworkInfo network;
  final DateTime firstSeen;
  final DateTime lastSeen;
  final DateTime? lastScanned;
  final int deviceCount;
  final int scanCount;
}

class DeviceIpVisit {
  const DeviceIpVisit(this.address, this.firstSeen, this.lastSeen);
  final String address;
  final DateTime firstSeen;
  final DateTime lastSeen;
}
