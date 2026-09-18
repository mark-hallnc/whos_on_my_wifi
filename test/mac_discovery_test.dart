import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whos_on_my_wifi/models/mac_address.dart';
import 'package:whos_on_my_wifi/models/network_device.dart';
import 'package:whos_on_my_wifi/models/network_info.dart';
import 'package:whos_on_my_wifi/models/scan_result.dart';
import 'package:whos_on_my_wifi/models/upnp_description.dart';
import 'package:whos_on_my_wifi/services/mac_device_enricher.dart';
import 'package:whos_on_my_wifi/services/neighbor_table_service.dart';
import 'package:whos_on_my_wifi/services/network_discovery_service.dart';
import 'package:whos_on_my_wifi/services/network_scanner.dart';
import 'package:whos_on_my_wifi/services/local_service_discovery_service.dart';
import 'package:whos_on_my_wifi/services/service_device_merger.dart';
import 'package:whos_on_my_wifi/services/ssdp_device_merger.dart';
import 'package:whos_on_my_wifi/services/vendor_lookup_service.dart';
import 'support/no_ssdp_discovery.dart';

const lan = NetworkInfo(
  id: 'lan',
  connectionType: NetworkConnectionType.wifi,
  localIpAddress: '192.168.1.2',
  ipv4PrefixLength: 30,
);
const channel = MethodChannel('whos_on_my_wifi/neighbors');
Map<String, Object?> snapshot({
  String arp = '',
  String neighbors = '',
  String? localMac,
}) => {
  'localIp': lan.localIpAddress,
  'interface': 'wlan0',
  'arp': arp,
  'neighbors': neighbors,
  'localMac': localMac,
};
const arpRow = '192.168.1.1 0x1 0x2 00:11:22:33:44:55 * wlan0';
NetworkDevice device({String? manufacturer}) => NetworkDevice(
  id: 'keep-id',
  ipAddress: '192.168.1.1',
  firstSeen: DateTime(2020),
  lastSeen: DateTime(2021),
  manufacturer: manufacturer,
  customName: 'My device',
  confidence: IdentificationConfidence.low,
);

class NoNsd implements LocalServiceDiscovery {
  @override
  Future<List<String>> discover({
    required NetworkInfo network,
    required ScanCancellation cancellation,
    required Future<void> Function() verifyNetwork,
    required Future<void> Function(ResolvedLocalService) onService,
  }) async => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));
  for (final input in ['00:11:22:aa:bb:cc', '00-11-22-AA-BB-CC']) {
    test(
      'normalizes $input',
      () => expect(MacAddress.parse(input)!.value, '00:11:22:AA:BB:CC'),
    );
  }
  for (final input in [
    '',
    '001122334455',
    '00:11-22:33:44:55',
    'gg:11:22:33:44:55',
    '00:00:00:00:00:00',
    'ff:ff:ff:ff:ff:ff',
    '02:00:00:00:00:00',
    '01:11:22:33:44:55',
  ]) {
    test(
      'rejects invalid/redacted/non-unicast $input',
      () => expect(MacAddress.parse(input), isNull),
    );
  }
  test(
    'U/L bit identifies local addresses without claiming randomization is certain',
    () {
      expect(
        MacAddress.parse('DA:12:34:56:78:90')!.isLocallyAdministered,
        isTrue,
      );
      expect(
        MacAddress.parse('00:11:22:33:44:55')!.isLocallyAdministered,
        isFalse,
      );
    },
  );
  late VendorLookupService vendors;
  setUp(() async {
    vendors = VendorLookupService(
      loader: () async =>
          '{"001122":"Fixture Vendor","da1234":"Incorrect Private Vendor"}',
    );
    await vendors.loadBundledDatabase();
  });
  test(
    'asset parser and case-insensitive map lookup; private/unknown skipped',
    () {
      expect(vendors.lookup('00-11-22-aa-bb-cc'), 'Fixture Vendor');
      expect(vendors.lookup('00:11:23:AA:BB:CC'), isNull);
      expect(vendors.lookup('DA:12:34:56:78:90'), isNull);
      expect(
        VendorLookupService.parse(
          '{"aabbcc":" Name ","invalid":"x","112233":4}',
        ),
        {'AABBCC': 'Name'},
      );
      expect(() => VendorLookupService.parse('[]'), throwsFormatException);
      expect(() => VendorLookupService.parse('broken'), throwsFormatException);
    },
  );
  test('database loads once, including simultaneous requests', () async {
    var loads = 0;
    final service = VendorLookupService(
      loader: () async {
        loads++;
        return '{"001122":"Vendor"}';
      },
    );
    await Future.wait([
      service.loadBundledDatabase(),
      service.loadBundledDatabase(),
    ]);
    await service.loadBundledDatabase();
    expect(loads, 1);
    expect(service.prefixCount, 1);
  });
  test(
    'bundled registry is complete and contains real vendor registrations',
    () async {
      final service = VendorLookupService(
        loader: () => File(VendorLookupService.assetPath).readAsString(),
      );
      await service.loadBundledDatabase();
      expect(service.prefixCount, 40163);
      expect(service.lookup('24:0A:C4:00:00:01'), contains('Espressif'));
    },
  );
  test(
    'parses complete ARP and neighbor rows, rejects incomplete/wrong interface/subnet',
    () {
      final found = NeighborTableService.parse(
        snapshot(
          arp:
              '$arpRow\n'
              '192.168.1.3 0x1 0x2 00:11:22:33:44:55 * wlan0\n'
              '192.168.1.1 0x1 0x0 00:11:22:33:44:56 * wlan0\n'
              '192.168.1.1 0x1 0x2 00:11:22:33:44:56 * rmnet0',
          neighbors:
              '192.168.1.1 dev wlan0 lladdr 00:11:22:33:44:55 STALE\n'
              '192.168.1.1 dev wlan0 lladdr 00:11:22:33:44:56 FAILED\n'
              '192.168.1.1 dev wlan0 INCOMPLETE\nmalformed\n'
              '192.168.2.1 dev wlan0 lladdr 00:11:22:33:44:55 REACHABLE',
        ),
        lan,
      );
      expect(found.length, 1);
      expect(found.single.mac.value, '00:11:22:33:44:55');
      expect(NeighborTableService.parse(null, lan), isEmpty);
      expect(
        NeighborTableService.parse(
          snapshot()..['localIp'] = '192.168.2.2',
          lan,
        ),
        isEmpty,
      );
    },
  );
  test(
    'conflicting MAC mappings are discarded; local interface address is separate',
    () {
      expect(
        NeighborTableService.parse(
          snapshot(
            arp: arpRow,
            neighbors:
                '192.168.1.1 dev wlan0 lladdr 00:11:22:33:44:56 REACHABLE',
          ),
          lan,
        ),
        isEmpty,
      );
      expect(
        NeighborTableService.parse(
          snapshot(localMac: '02:00:00:00:00:00'),
          lan,
        ),
        isEmpty,
      );
      expect(
        NeighborTableService.parse(
          snapshot(localMac: 'DA:12:34:56:78:90'),
          lan,
        ).single.ip,
        lan.localIpAddress,
      );
    },
  );
  for (final explicit in [null, 'Specific manufacturer']) {
    test('IP merge preserves identity and stronger metadata ($explicit)', () {
      final original = device(manufacturer: explicit);
      final devices = {original.ipAddress: original};
      final rows = NeighborTableService.parse(snapshot(arp: arpRow), lan);
      MacDeviceEnricher.merge(devices, rows, vendors);
      MacDeviceEnricher.merge(devices, rows, vendors);
      final result = devices.values.single;
      expect(result.id, 'keep-id');
      expect(result.customName, 'My device');
      expect(result.firstSeen, original.firstSeen);
      expect(result.lastSeen, original.lastSeen);
      expect(result.manufacturer, explicit ?? 'Fixture Vendor');
      expect(result.macVendor, 'Fixture Vendor');
      expect(result.confidence, IdentificationConfidence.low);
      expect(result.type, DeviceType.unknown);
      expect(result.discoveryEvidence.length, 1);
      final empty = <String, NetworkDevice>{};
      MacDeviceEnricher.merge(empty, rows, vendors);
      expect(empty, isEmpty);
    });
  }
  test(
    'private MAC clears prior OUI, but retains independently reported manufacturer',
    () {
      final original = device(manufacturer: 'UPnP maker');
      final devices = {original.ipAddress: original};
      MacDeviceEnricher.merge(
        devices,
        NeighborTableService.parse(snapshot(arp: arpRow), lan),
        vendors,
      );
      MacDeviceEnricher.merge(devices, [
        NeighborObservation(
          original.ipAddress,
          MacAddress.parse('DA:12:34:56:78:90')!,
          'test',
        ),
      ], vendors);
      expect(devices.values.single.isPrivateMac, isTrue);
      expect(devices.values.single.macVendor, isNull);
      expect(devices.values.single.manufacturer, 'UPnP maker');
    },
  );
  test('later UPnP overrides OUI; mDNS preserves MAC provenance', () {
    final original = device();
    final devices = {original.ipAddress: original};
    MacDeviceEnricher.merge(
      devices,
      NeighborTableService.parse(snapshot(arp: arpRow), lan),
      vendors,
    );
    ServiceDeviceMerger.merge(
      devices,
      ResolvedLocalService(
        name: 'Service',
        type: '_http._tcp.',
        port: 80,
        addresses: [original.ipAddress],
      ),
      lan,
    );
    expect(devices.values.single.reportedManufacturer, isNull);
    SsdpDeviceMerger.merge(
      devices,
      SsdpAdvertisement(original.ipAddress, {'st': 'upnp:rootdevice'}),
      lan,
      description: UpnpDescription({'manufacturer': 'Specific maker'}, []),
      location: Uri.parse('http://192.168.1.1/device.xml'),
    );
    expect(devices.values.single.manufacturer, 'Specific maker');
    expect(devices.values.single.macVendor, 'Fixture Vendor');
  });
  test('platform access denial gracefully returns no MAC', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (call) async => throw PlatformException(code: 'permission_denied'),
    );
    expect(
      await const NeighborTableService().read(lan, ScanCancellation()),
      isEmpty,
    );
  });
  test('native cancellation returns promptly and ignores late rows', () async {
    final pending = Completer<Object?>();
    final entered = Completer<void>();
    var stopped = false;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'cancel') {
        stopped = true;
        return null;
      }
      entered.complete();
      return pending.future;
    });
    final token = ScanCancellation();
    final reading = const NeighborTableService().read(lan, token);
    await entered.future;
    token.cancel();
    expect(await reading, isEmpty);
    pending.complete(snapshot(arp: arpRow));
    await Future<void>.delayed(Duration.zero);
    expect(stopped, isTrue);
  });
  for (final changed in [false, true]) {
    test(
      'scanner enriches after discovery and gates changed network: $changed',
      () async {
        var read = false;
        messenger.setMockMethodCallHandler(channel, (call) async {
          if (call.method != 'read') return null;
          read = true;
          return snapshot(arp: arpRow);
        });
        final result =
            await NetworkScanner(
              probe: (_) async => ['TCP'],
              serviceDiscovery: NoNsd(),
              ssdpDiscovery: const NoSsdpDiscovery(),
              vendorLookup: vendors,
            ).discover(
              network: lan,
              verifyNetwork: (_) async =>
                  changed && read ? 'Network changed. Scan stopped.' : null,
            );
        expect(read, isTrue);
        expect(
          result.state,
          changed ? ScanState.cancelled : ScanState.completed,
        );
        expect(
          result.devices
              .singleWhere((d) => d.ipAddress == '192.168.1.1')
              .macAddress,
          changed ? isNull : '00:11:22:33:44:55',
        );
      },
    );
  }
}
