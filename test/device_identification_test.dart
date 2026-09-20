import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whos_on_my_wifi/data/database/app_database.dart'
    show AppDatabase;
import 'package:whos_on_my_wifi/models/network_device.dart';
import 'package:whos_on_my_wifi/models/discovered_service.dart';
import 'package:whos_on_my_wifi/models/upnp_description.dart';
import 'package:whos_on_my_wifi/repositories/persistent_device_repository.dart';
import 'package:whos_on_my_wifi/services/device_identification_service.dart';
import 'package:whos_on_my_wifi/services/service_device_merger.dart';
import 'package:whos_on_my_wifi/utils/identity_text.dart';
import 'package:whos_on_my_wifi/utils/device_presentation.dart';
import 'persistent_device_repository_test.dart' show scan, network;

final time = DateTime.utc(2026, 9, 19);
DiscoveredService advertised(
  String type, {
  String name = 'Living Room',
  Map<String, String> txt = const {},
}) => DiscoveredService(
  name: name,
  type: type,
  discoveryMethod: 'mDNS / Android NSD',
  attributes: txt,
);
NetworkDevice raw({
  String? vendor,
  String? manufacturer,
  String? hostname,
  String? name,
  String? custom,
  String? model,
  bool gateway = false,
  bool self = false,
  String mac = '00:11:22:33:44:55',
  Map<String, String> upnp = const {},
  List<DiscoveredService> services = const [],
}) => NetworkDevice(
  id: 'device',
  ipAddress: '192.168.1.42',
  firstSeen: time,
  lastSeen: time,
  macAddress: mac,
  macVendor: vendor,
  manufacturer: manufacturer,
  hostname: hostname,
  discoveredName: name,
  customName: custom,
  modelName: model,
  isGateway: gateway,
  isCurrentDevice: self,
  services: services,
  upnpDescription: upnp.isEmpty ? null : UpnpDescription(upnp, []),
);
NetworkDevice identify(NetworkDevice d) =>
    DeviceIdentificationService.identify(d);

const samsung = {
  'friendlyName': 'Living Room TV',
  'manufacturer': 'Samsung Electronics Co.,Ltd',
  'modelName': 'Samsung Smart TV',
  'modelNumber': '1234',
  'modelDescription': 'Living room television',
  'deviceType': 'urn:schemas-upnp-org:device:MediaRenderer:1',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('HP OUI + IPP + hostname is a high-confidence printer', () {
    final d = identify(
      raw(
        vendor: 'Hewlett-Packard',
        hostname: 'HP-LaserJet.local.',
        services: [advertised('_ipp._tcp.', name: 'HP LaserJet Pro')],
      ),
    );
    expect(d.type, DeviceType.printer);
    expect(d.confidence, IdentificationConfidence.high);
    expect(d.manufacturer, 'HP');
    expect(d.discoveredName, 'HP LaserJet Pro');
  });
  test(
    'Cast model is real metadata; Cast alone never implies Chromecast or TV',
    () {
      final d = identify(
        raw(
          vendor: 'Google LLC',
          services: [
            advertised(
              '_googlecast._tcp.',
              name: 'Chromecast-0123456789abcdef0123456789abcdef',
              txt: {'fn': 'Living Room', 'md': 'Chromecast'},
            ),
          ],
        ),
      );
      expect(d.modelName, 'Chromecast');
      expect(d.type, DeviceType.mediaDevice);
      expect(d.discoveredName, 'Living Room');
      expect(d.confidence, IdentificationConfidence.medium);
      final bare = identify(raw(services: [advertised('_googlecast._tcp.')]));
      expect(bare.type, DeviceType.mediaDevice);
      expect(bare.modelName, isNull);
      final tv = identify(
        raw(
          services: [
            advertised('_googlecast._tcp.', txt: {'md': 'Samsung Smart TV'}),
          ],
        ),
      );
      expect(tv.type, DeviceType.television);
    },
  );
  test('Samsung OUI and generic HTTP do not imply TV', () {
    for (final services in [
      <DiscoveredService>[],
      [advertised('_http._tcp.', name: '_http')],
    ]) {
      final d = identify(
        raw(vendor: 'Samsung Electronics Co.,Ltd', services: services),
      );
      expect(d.manufacturer, 'Samsung');
      expect(d.type, DeviceType.unknown);
      expect(d.confidence, IdentificationConfidence.low);
    }
  });
  test('Espressif is a weak IoT hint, never a guessed product', () {
    final d = identify(raw(vendor: 'Espressif Inc.'));
    expect(d.type, DeviceType.iot);
    expect(d.confidence, IdentificationConfidence.low);
    expect(d.modelName, isNull);
    expect(d.displayName, 'Unknown device');
  });
  test('gateway role plus UPnP gateway is high confidence', () {
    final d = identify(
      raw(
        gateway: true,
        custom: 'My router',
        upnp: {
          'deviceType': 'urn:schemas-upnp-org:device:InternetGatewayDevice:1',
        },
      ),
    );
    expect(d.type, DeviceType.router);
    expect(d.confidence, IdentificationConfidence.high);
    expect(d.displayName, 'Router / Gateway');
  });
  test('Roku MediaRenderer is media, not automatically a television', () {
    final d = identify(
      raw(
        vendor: 'Roku',
        upnp: {
          'friendlyName': 'Living Room Roku',
          'manufacturer': 'Roku',
          'deviceType': 'urn:schemas-upnp-org:device:MediaRenderer:1',
        },
      ),
    );
    expect(d.type, DeviceType.mediaDevice);
    expect(d.confidence, IdentificationConfidence.high);
  });
  test('Apple with AirPlay is media capability, not Apple TV/phone/Mac', () {
    final d = identify(
      raw(vendor: 'Apple, Inc.', services: [advertised('_airplay._tcp.')]),
    );
    expect(d.type, DeviceType.mediaDevice);
    expect(d.confidence, IdentificationConfidence.medium);
    expect(d.modelName, isNull);
    expect(
      identify(raw(services: [advertised('_airplay._tcp.')])).type,
      DeviceType.unknown,
    );
  });
  test('TCP-only and weak hostname stay low confidence', () {
    expect(identify(raw()).displayName, 'Unknown device');
    expect(identify(raw()).type, DeviceType.unknown);
    expect(identify(raw()).confidence, IdentificationConfidence.low);
    expect(
      identify(raw(hostname: 'office.local')).confidence,
      IdentificationConfidence.low,
    );
  });
  test('workstation, camera and thermostat hints do not invent operating systems', () {
    final workstation = identify(raw(services: [advertised('_workstation._tcp.')]));
    expect(workstation.type, DeviceType.computer);
    expect(workstation.type.label, 'Computer');
    expect(identify(raw(upnp: {'modelName': 'Network Camera 200'})).type, DeviceType.camera);
    expect(identify(raw(upnp: {'modelName': 'Nest Thermostat'})).type, DeviceType.thermostat);
  });
  test('printer service without supporting identity is medium, not high', () {
    expect(identify(raw(services: [advertised('_ipp._tcp.')])).confidence, IdentificationConfidence.medium);
  });
  test('direct protocol disagreement does not combine incompatible model/vendor', () {
    final d = identify(raw(upnp: {'manufacturer': 'Samsung'}, services: [advertised('_ipp._tcp.',
      txt: {'usb_MFG': 'HP', 'usb_MDL': 'LaserJet Pro M404'})]));
    expect(d.manufacturer, 'Samsung');
    expect(d.modelName, isNull);
    expect(d.identificationNotes, isNotEmpty);
  });
  test('existing user fields survive centralized re-identification', () {
    final prior = raw(custom: 'Garage').withPresentation(classification: DeviceClassification.mine, notes: 'User note');
    final d = DeviceIdentificationService.identify(raw(upnp: samsung), previous: prior);
    expect(d.customName, 'Garage');
    expect(d.classification, DeviceClassification.mine);
    expect(d.notes, 'User note');
  });
  test(
    'current device and gateway labels precede user name, then user name wins',
    () {
      expect(
        identify(
          raw(self: true, gateway: true, custom: 'Mine', upnp: samsung),
        ).displayName,
        'This device',
      );
      expect(
        identify(raw(gateway: true, custom: 'Mine', upnp: samsung)).displayName,
        'Router / Gateway',
      );
      expect(
        identify(raw(custom: 'My screen', upnp: samsung)).displayName,
        'My screen',
      );
      expect(
        identify(raw(upnp: samsung, hostname: 'older.local')).displayName,
        'Living Room TV',
      );
      expect(raw(hostname: 'office.local.').displayName, 'office');
    },
  );
  for (final bad in [
    'localhost',
    'android.local.',
    'unknown',
    'device',
    '_http',
    '_googlecast._tcp.',
    '123456',
    '192.168.1.42',
    'uuid:01234567-89ab-cdef-0123-456789abcdef',
    '0123456789abcdef0123456789abcdef',
  ]) {
    test('rejects generic/protocol name $bad', () {
      expect(IdentityText.name(bad), isNull);
      expect(identify(raw(name: bad)).displayName, 'Unknown device');
    });
  }
  test(
    'names preserve case/punctuation and raw hostname remains accessible',
    () {
      final d = identify(raw(hostname: 'living-room-TV.local.'));
      expect(d.discoveredName, 'living-room-TV');
      expect(d.hostname, 'living-room-TV.local.');
      expect(
        IdentityText.name("  Bob's   TV (Office)!  "),
        "Bob's TV (Office)!",
      );
    },
  );
  test('service instance becomes discoveredName, never hostname', () {
    final devices = <String, NetworkDevice>{};
    ServiceDeviceMerger.merge(
      devices,
      ResolvedLocalService(
        name: 'Office Printer',
        type: '_ipp._tcp.',
        port: 631,
        addresses: ['192.168.1.42'],
      ),
      network,
    );
    expect(devices.values.single.hostname, isNull);
    expect(devices.values.single.discoveredName, 'Office Printer');
  });
  test('manufacturer aliases are narrow and original text is retained', () {
    expect(IdentityText.manufacturer('Samsung Electronics Co.,Ltd'), 'Samsung');
    expect(IdentityText.manufacturer('Google LLC'), 'Google');
    expect(IdentityText.manufacturer('Espressif Inc.'), 'Espressif');
    expect(
      IdentityText.manufacturer('Hewlett Packard Enterprise'),
      'Hewlett Packard Enterprise',
    );
    final d = identify(raw(upnp: samsung));
    expect(d.reportedManufacturer, 'Samsung Electronics Co.,Ltd');
    expect(d.identitySummary, 'Samsung Smart TV • Television');
    expect(d.modelNumber, '1234');
  });
  test('protocol vendor wins conflicting OUI and records the reason', () {
    final d = identify(raw(vendor: 'Google LLC', upnp: samsung));
    expect(d.manufacturer, 'Samsung');
    expect(d.macVendor, 'Google LLC');
    expect(d.identificationNotes, isNotEmpty);
    expect(d.modelName, 'Samsung Smart TV');
  });
  test('private MAC drops OUI only; protocol identity remains strong', () {
    final private = identify(
      raw(mac: 'DA:11:22:33:44:55', vendor: 'Google LLC'),
    );
    expect(private.manufacturer, isNull);
    expect(private.type, DeviceType.unknown);
    expect(private.confidence, IdentificationConfidence.low);
    final explicit = identify(
      raw(mac: 'DA:11:22:33:44:55', vendor: 'Google LLC', upnp: samsung),
    );
    expect(explicit.manufacturer, 'Samsung');
    expect(explicit.confidence, IdentificationConfidence.high);
  });
  test(
    'independent name/model agreement raises confidence, duplicate services do not',
    () {
      final d = raw(
        upnp: {'friendlyName': 'Office', 'modelName': 'LaserJet Pro M404'},
      );
    expect(identify(d).confidence, IdentificationConfidence.medium);
      expect(
        identify(
          raw(
            upnp: d.upnpDescription!.fields,
            services: [advertised('_http._tcp.', name: 'Office')],
          ),
        ).confidence,
        IdentificationConfidence.high,
      );
      final repeated = identify(
        raw(
          services: List.filled(30, advertised('_http._tcp.', name: 'Office')),
        ),
      );
      expect(repeated.confidence, IdentificationConfidence.low);
      expect(repeated.services.length, 1);
    },
  );
  test('service order is deterministic and identification is idempotent', () {
    final services = [
      advertised('_googlecast._tcp.', name: 'Z room'),
      advertised('_ipp._tcp.', name: 'A printer'),
    ];
    final first = identify(raw(services: services));
    final second = identify(raw(services: services.reversed.toList()));
    expect(first.discoveredName, second.discoveredName);
    expect(first.type, second.type);
    expect(identify(first).identificationQuality, first.identificationQuality);
    expect(identify(first).confidence, first.confidence);
  });
  test(
    'stronger fresh evidence replaces weak IoT, weaker scans retain rich metadata',
    () {
      final weak = identify(raw(vendor: 'Espressif Inc.'));
      final upgraded = DeviceIdentificationService.identify(
        raw(services: [advertised('_ipp._tcp.')]),
        previous: weak,
      );
      expect(upgraded.type, DeviceType.printer);
      final rich = identify(raw(upnp: samsung));
      final later = DeviceIdentificationService.identify(
        raw(name: 'Samsung', model: 'Generic model'),
        previous: rich,
      );
      expect(later.discoveredName, rich.discoveredName);
      expect(later.modelName, rich.modelName);
      expect(later.type, rich.type);
      expect(later.confidence, rich.confidence);
    },
  );
  test(
    'changed reported manufacturer does not inherit incompatible old model',
    () {
      final old = identify(raw(upnp: samsung));
      final next = DeviceIdentificationService.identify(
        raw(upnp: {'manufacturer': 'Roku'}),
        previous: old,
      );
      expect(next.manufacturer, 'Roku');
      expect(next.modelName, isNull);
    },
  );
  test('printer TXT metadata is protocol-scoped and beats OUI', () {
    final d = identify(
      raw(
        vendor: 'Google LLC',
        services: [
          advertised(
            '_ipp._tcp.',
            txt: {'usb_MFG': 'HP', 'usb_MDL': 'LaserJet Pro M404'},
          ),
        ],
      ),
    );
    expect(d.manufacturer, 'HP');
    expect(d.modelName, 'LaserJet Pro M404');
    final ignored = identify(
      raw(
        services: [
          advertised('_http._tcp.', txt: {'usb_MFG': 'HP', 'md': 'Chromecast'}),
        ],
      ),
    );
    expect(ignored.manufacturer, isNull);
    expect(ignored.modelName, isNull);
  });
  test('friendly labels keep original raw types and distinguish protocols', () {
    const labels = {
      '_http._tcp.': 'Web Interface',
      '_https._tcp.': 'Secure Web Interface',
      '_googlecast._tcp.': 'Google Cast',
      '_airplay._tcp.': 'AirPlay',
      '_raop._tcp.': 'AirPlay Audio',
      '_ipp._tcp.': 'Printer',
      '_ipps._tcp.': 'Secure Printer',
      '_workstation._tcp.': 'Workstation',
      'urn:schemas-upnp-org:service:AVTransport:1': 'Media Playback',
      'urn:schemas-upnp-org:service:RenderingControl:1': 'Media Controls',
      'urn:schemas-upnp-org:service:WANIPConnection:1': 'Internet Gateway',
    };
    for (final e in labels.entries) {
      final s = advertised(e.key);
      expect(s.label, e.value);
      expect(s.type, e.key);
    }
  });
  test(
    'persisted quality protects identity and edits across weaker scans',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = PersistentDeviceRepository(db);
      try {
        final first = (await repo.saveScan(
          scan([raw(upnp: samsung)]),
        )).devices.single;
        await repo.updateDevice(
          first.id,
          customName: 'My TV',
          classification: DeviceClassification.mine,
          notes: 'Keep this',
        );
        final next = (await repo.saveScan(
          scan([raw(manufacturer: 'Samsung', name: 'device')], minute: 1),
        )).devices.single;
        expect(next.id, first.id);
        expect(next.discoveredName, 'Living Room TV');
        expect(next.modelName, 'Samsung Smart TV');
        expect(next.type, DeviceType.television);
        expect(next.confidence, IdentificationConfidence.high);
        expect(next.customName, 'My TV');
        expect(next.notes, 'Keep this');
        expect(next.classification, DeviceClassification.mine);
        final row = await db
            .customSelect('SELECT details_json FROM stored_devices')
            .getSingle();
        final data =
            jsonDecode(row.read<String>('details_json'))
                as Map<String, dynamic>;
        expect(data['identificationQuality']['model'], 90);
        // Older databases contain the same schema without these optional JSON keys.
        data.remove('identificationQuality');
        data.remove('identificationNotes');
        await db.customStatement('UPDATE stored_devices SET details_json=?', [
          jsonEncode(data),
        ]);
        expect((await repo.getDevice(first.id))!.modelName, 'Samsung Smart TV');
      } finally {
        await repo.close();
      }
    },
  );
}
