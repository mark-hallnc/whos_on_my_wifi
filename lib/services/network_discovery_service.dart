import '../models/scan_result.dart';

/// Future Android discovery implementations live behind this boundary.
/// No implementation or networking is provided in the UI foundation.
abstract interface class NetworkDiscoveryService {
  Future<ScanResult> discover();
}
