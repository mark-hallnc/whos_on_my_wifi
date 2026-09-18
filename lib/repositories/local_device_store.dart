import 'package:flutter/foundation.dart';
import '../models/network_device.dart';
import '../models/network_info.dart';
import '../models/saved_network.dart';
import '../models/scan_result.dart';
import 'device_repository.dart';

abstract class LocalDeviceStore extends ChangeNotifier
    implements DeviceRepository {
  Future<ScanResult> loadCurrentNetworkSnapshot(NetworkInfo network);
  Future<ScanResult> saveScan(ScanResult result);
  Future<List<SavedNetwork>> getSavedNetworks();
  Future<List<NetworkDevice>> getDevicesForNetwork(int networkId);
  Future<NetworkDevice?> getDevice(String id);
  Future<List<DeviceIpVisit>> getDeviceHistory(String id);
  Future<void> updateDevice(
    String id, {
    required String? customName,
    required DeviceClassification classification,
    required String notes,
  });
  Future<void> close();
  void clearPresence();
}
