/// Transaction outcome, never a permanent device property. IDs are database IDs
/// in the same `device:<id>` format used by NetworkDevice.
class ScanReconciliation {
  ScanReconciliation({
    required this.networkId,
    required this.scanKey,
    required this.isBaseline,
    required this.isSuccessful,
    this.isDuplicate = false,
    Set<String> insertedDeviceIds = const {},
    Set<String> matchedDeviceIds = const {},
    Set<String> updatedDeviceIds = const {},
    Set<String> offlineDeviceIds = const {},
    Set<String> newDeviceIds = const {},
  }) : insertedDeviceIds = Set.unmodifiable(insertedDeviceIds),
       matchedDeviceIds = Set.unmodifiable(matchedDeviceIds),
       updatedDeviceIds = Set.unmodifiable(updatedDeviceIds),
       offlineDeviceIds = Set.unmodifiable(offlineDeviceIds),
       newDeviceIds = Set.unmodifiable(newDeviceIds);

  final int networkId;
  final String scanKey;
  final bool isBaseline;
  final bool isSuccessful;
  final bool isDuplicate;
  final Set<String> insertedDeviceIds;
  final Set<String> matchedDeviceIds;
  final Set<String> updatedDeviceIds;
  final Set<String> offlineDeviceIds;

  /// Newly inserted external devices, excluding the initial network baseline.
  final Set<String> newDeviceIds;
}
