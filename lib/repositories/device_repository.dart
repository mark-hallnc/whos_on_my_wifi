import '../models/scan_result.dart';

/// Reads the latest available snapshot without initiating discovery.
abstract interface class DeviceRepository {
  Future<ScanResult> loadSnapshot();
}
