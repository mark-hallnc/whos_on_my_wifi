import 'network_device.dart';
import 'network_info.dart';
import 'scan_reconciliation.dart';

enum ScanState {
  idle,
  preparing,
  running,
  discoveringServices,
  completed,
  cancelled,
  failed,
  subnetTooLarge,
}

/// A snapshot; a null completion time means no scan has been completed.
class ScanResult {
  ScanResult({
    required this.network,
    required List<NetworkDevice> devices,
    this.startedAt,
    this.completedAt,
    this.isMock = false,
    this.state = ScanState.idle,
    this.totalCandidates = 0,
    this.addressesChecked = 0,
    this.message,
    this.foundCount,
    this.reconciliation,
    List<String> discoveryMethods = const [],
    List<String> limitations = const [],
  }) : devices = List.unmodifiable(devices),
       discoveryMethods = List.unmodifiable(discoveryMethods),
       limitations = List.unmodifiable(limitations);

  /// Preserve partial results when preparation or cancellation changes state.
  ScanResult withState(
    ScanState state, {
    String? message,
    bool resetProgress = false,
  }) => ScanResult(
    network: network,
    devices: devices,
    startedAt: startedAt,
    completedAt: resetProgress ? null : completedAt,
    isMock: isMock,
    state: state,
    message: message,
    totalCandidates: resetProgress ? 0 : totalCandidates,
    addressesChecked: resetProgress ? 0 : addressesChecked,
    discoveryMethods: discoveryMethods,
    limitations: limitations,
    foundCount: resetProgress ? null : foundCount,
  );

  final NetworkInfo network;
  final ScanReconciliation? reconciliation;
  final ScanState state;
  final int totalCandidates;
  final int addressesChecked;
  final String? message;
  final int? foundCount;
  int get devicesFound => foundCount ?? devices.length;
  final List<NetworkDevice> devices;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final bool isMock;
  final List<String> discoveryMethods;
  final List<String> limitations;
}
