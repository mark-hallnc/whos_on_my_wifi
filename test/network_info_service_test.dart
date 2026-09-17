import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whos_on_my_wifi/models/network_info.dart';
import 'package:whos_on_my_wifi/services/network_info_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('network_info_test');
  const service = NetworkInfoService(channel: channel);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('maps native metadata and derives a non-/24 subnet', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => {
        'networkId': '100',
        'connectionType': 'wifi',
        'isWifiConnected': true,
        'ssid': 'My Wi-Fi',
        'ipv4Address': '192.168.10.77',
        'ipv4PrefixLength': 26,
        'gateway': '192.168.10.65',
        'dnsServers': ['192.168.10.65', '1.1.1.1'],
        'interfaceName': 'wlan0',
        'ipv6Addresses': [
          {'address': 'fe80::1234%wlan0', 'prefixLength': 64},
        ],
      },
    );
    final info = await service.getCurrentNetwork();
    expect(info.name, 'My Wi-Fi');
    expect(info.isWifiConnected, isTrue);
    expect(info.subnet, '192.168.10.64/26');
    expect(info.broadcastAddress, '192.168.10.127');
    expect(info.gatewayAddress, '192.168.10.65');
    expect(info.dnsServers, ['192.168.10.65', '1.1.1.1']);
    expect(info.ipv6Addresses.single.cidr, 'fe80::1234%wlan0/64');
  });
  test('missing prefix is not guessed; redacted SSID stays unavailable', () {
    final info = NetworkInfoService.fromPlatform({
      'connectionType': 'wifi',
      'ssid': '<unknown ssid>',
      'ipv4Address': '10.0.0.3',
    });
    expect(info.subnet, isNull);
    expect(info.name, isNull);
    expect(info.localIpAddress, '10.0.0.3');
  });
  test('VPN addresses are not presented as a broadcast LAN', () {
    final info = NetworkInfoService.fromPlatform({
      'connectionType': 'vpn',
      'ipv4Address': '10.8.0.2',
      'ipv4PrefixLength': 24,
    });
    expect(info.connectionType, NetworkConnectionType.vpn);
    expect(info.broadcastAddress, isNull);
  });
  test('IPv6-only connection remains usable without IPv4', () {
    final info = NetworkInfoService.fromPlatform({
      'connectionType': 'wifi',
      'ipv6Addresses': [
        {'address': '2001:db8::1', 'prefixLength': 64},
      ],
    });
    expect(info.localIpAddress, isNull);
    expect(info.subnet, isNull);
    expect(info.ipv6Addresses.single.prefixLength, 64);
  });
  test(
    'permission errors clear addresses and explain unavailability',
    () async {
      messenger.setMockMethodCallHandler(channel, (_) async {
        throw PlatformException(code: 'permission_denied');
      });
      final info = await service.getCurrentNetwork();
      expect(info.connectionType, NetworkConnectionType.unknown);
      expect(info.localIpAddress, isNull);
      expect(info.notice, contains('did not allow'));
    },
  );
  test(
    'non-Android platforms return unavailable rather than sample data',
    () async {
      final info = await service.getCurrentNetwork();
      expect(info.name, isNull);
      expect(info.localIpAddress, isNull);
      expect(info.notice, contains('Android'));
    },
  );
}
