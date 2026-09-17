import '../models/network_info.dart';
import '../models/scan_result.dart';
import 'device_repository.dart';

/// Empty until discovery starts. Example devices are only used in previews.
class SessionDeviceRepository implements DeviceRepository {
  @override
  Future<ScanResult> loadSnapshot() async => ScanResult(
    network: const NetworkInfo(id: 'not-scanned'),
    devices: [],
  );
}
