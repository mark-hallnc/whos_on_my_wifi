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

enum ScanPhase {
  preparing,
  discoveringHosts,
  discoveringServices,
  identifying,
  finalizing,
}

/// Session diagnostics, never used as device identity or persisted history.
class ScanDiagnostics {
  ScanDiagnostics({
    required this.elapsed,
    required this.tcpHosts,
    required this.nsdOnlyHosts,
    required this.ssdpOnlyHosts,
    required this.serviceOnlyHosts,
    required this.skippedProbes,
    required this.devicesWithMac,
    required this.identifiedDevices,
    required Map<String, Duration> durations,
  }) : durations = Map.unmodifiable(durations);
  final Duration elapsed;
  final int tcpHosts, nsdOnlyHosts, ssdpOnlyHosts, serviceOnlyHosts;
  final int skippedProbes, devicesWithMac, identifiedDevices;

  /// Independent tasks overlap; these durations must not be added together.
  final Map<String, Duration> durations;
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
    this.phase = ScanPhase.preparing,
    this.diagnostics,
    this.possibleIsolation = false,
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
    phase: resetProgress ? ScanPhase.preparing : phase,
    diagnostics: resetProgress ? null : diagnostics,
    possibleIsolation: resetProgress ? false : possibleIsolation,
  );

  final NetworkInfo network;
  final ScanPhase phase;
  final ScanDiagnostics? diagnostics;
  final bool possibleIsolation;
  int get onlineDevices => devices.where((device) => device.isOnline).length;
  int get knownDevices => devices.length;
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
