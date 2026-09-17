import 'network_device.dart';
import 'network_info.dart';

/// A snapshot; a null completion time means no scan has been completed.
class ScanResult {
  ScanResult({
    required this.network,
    required List<NetworkDevice> devices,
    this.startedAt,
    this.completedAt,
    this.isMock = false,
    List<String> discoveryMethods = const [],
    List<String> limitations = const [],
  }) : devices = List.unmodifiable(devices),
       discoveryMethods = List.unmodifiable(discoveryMethods),
       limitations = List.unmodifiable(limitations);

  final NetworkInfo network;
  final List<NetworkDevice> devices;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final bool isMock;
  final List<String> discoveryMethods;
  final List<String> limitations;
}
