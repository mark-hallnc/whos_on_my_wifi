import '../models/network_device.dart';
import '../models/scan_result.dart';
import 'device_identity_service.dart';

/// Presentation only: absence during an unfinished scan never writes offline state.
class ScanHistoryOverlay {
  static ScanResult merge(ScanResult scan, List<NetworkDevice> saved) {
    final remaining = saved
        .map((d) => d.withPresentation(online: false, isNew: false))
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
    return ScanResult(
      network: scan.network,
      devices: [...result, ...remaining],
      startedAt: scan.startedAt,
      completedAt: scan.completedAt,
      state: scan.state,
      totalCandidates: scan.totalCandidates,
      addressesChecked: scan.addressesChecked,
      message: scan.message,
      discoveryMethods: scan.discoveryMethods,
      limitations: scan.limitations,
      foundCount: scan.devicesFound,
    );
  }
}
