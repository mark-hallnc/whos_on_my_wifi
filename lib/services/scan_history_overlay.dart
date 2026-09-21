import '../models/network_device.dart';
import '../models/scan_result.dart';
import '../models/network_info.dart';
import 'device_identity_service.dart';

/// Presentation only: absence during an unfinished scan never writes offline state.
class ScanHistoryOverlay {
  /// Select cards, never database identities. A live sighting owns its IP;
  /// conflicting historical identities remain available in saved history.
  static ScanResult present(ScanResult scan, {NetworkInfo? activeNetwork}) {
    final active =
        !scan.isMock &&
        activeNetwork != null &&
        DeviceIdentityService.networkKey(activeNetwork) != null &&
        DeviceIdentityService.networkKey(activeNetwork) ==
            DeviceIdentityService.networkKey(scan.network);
    final byIp = <String, NetworkDevice>{};
    for (var device in scan.devices) {
      if (!scan.isMock && activeNetwork != null && !active) {
        device = device.withPresentation(online: false);
      }
      if (device.isCurrentDevice && active) {
        device = device.withPresentation(
          online: true,
          ipAddress: activeNetwork.localIpAddress,
        );
      }
      final prior = byIp[device.ipAddress];
      if (prior == null ||
          (device.isOnline && !prior.isOnline) ||
          (device.isOnline == prior.isOnline && _prefer(device, prior))) {
        byIp[device.ipAddress] = device;
      }
    }
    return ScanResult(
      network: scan.network,
      devices: byIp.values.toList(),
      state: scan.state,
      phase: scan.phase,
      startedAt: scan.startedAt,
      completedAt: scan.completedAt,
      isMock: scan.isMock,
      totalCandidates: scan.totalCandidates,
      addressesChecked: scan.addressesChecked,
      message: scan.message,
      foundCount: scan.foundCount,
      reconciliation: scan.reconciliation,
      diagnostics: scan.diagnostics,
      possibleIsolation: scan.possibleIsolation,
      discoveryMethods: scan.discoveryMethods,
      limitations: scan.limitations,
    );
  }

  static bool _prefer(NetworkDevice a, NetworkDevice b) {
    if (a.isCurrentDevice != b.isCurrentDevice) return a.isCurrentDevice;
    final time = a.lastSeen.compareTo(b.lastSeen);
    if (time != 0) return time > 0;
    if ((a.customName?.isNotEmpty ?? false) !=
        (b.customName?.isNotEmpty ?? false)) {
      return a.customName?.isNotEmpty ?? false;
    }
    return a.confidence.index > b.confidence.index;
  }

  static ScanResult merge(ScanResult scan, List<NetworkDevice> saved) {
    final remaining = saved
        .map(
          (d) => d.withPresentation(
            online: scan.state == ScanState.completed ? false : d.isOnline,
            isNew: false,
          ),
        )
        .toList();
    final result = <NetworkDevice>[];
    for (final fresh in scan.devices) {
      final keys = DeviceIdentityService.strongKeys(fresh).toSet();
      final matches = remaining
          .where(
            (old) =>
                !DeviceIdentityService.conflicts(old, fresh) &&
                (keys
                        .intersection(
                          DeviceIdentityService.strongKeys(old).toSet(),
                        )
                        .isNotEmpty ||
                    DeviceIdentityService.fallbackMatch(old, fresh)),
          )
          .toList();
      if (matches.length == 1) {
        final old = matches.single;
        remaining.remove(old);
        result.add(
          fresh.withPresentation(
            id: old.id,
            customName: old.customName,
            classification: old.classification,
            notes: old.notes,
            firstSeen: old.firstSeen,
            previousIpAddresses: old.previousIpAddresses,
          ),
        );
      } else {
        result.add(fresh);
      }
    }
    final observedIps = result.map((device) => device.ipAddress).toSet();
    return present(
      ScanResult(
        network: scan.network,
        devices: [
          ...result,
          ...remaining.where(
            (device) => !observedIps.contains(device.ipAddress),
          ),
        ],
        startedAt: scan.startedAt,
        completedAt: scan.completedAt,
        state: scan.state,
        phase: scan.phase,
        diagnostics: scan.diagnostics,
        possibleIsolation: scan.possibleIsolation,
        totalCandidates: scan.totalCandidates,
        addressesChecked: scan.addressesChecked,
        message: scan.message,
        discoveryMethods: scan.discoveryMethods,
        limitations: scan.limitations,
        foundCount: scan.devicesFound,
      ),
    );
  }
}
