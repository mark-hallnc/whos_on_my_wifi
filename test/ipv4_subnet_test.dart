import 'package:flutter_test/flutter_test.dart';
import 'package:whos_on_my_wifi/utils/ipv4_subnet.dart';

void main() {
  test('192.168.1.104/24', () {
    final subnet = Ipv4Subnet('192.168.1.104', 24);
    expect(subnet.networkAddress, '192.168.1.0');
    expect(subnet.broadcastAddress, '192.168.1.255');
    expect(subnet.subnetMask, '255.255.255.0');
    expect(subnet.cidr, '192.168.1.0/24');
  });
  test('192.168.10.77/26 uses the actual prefix', () {
    final subnet = Ipv4Subnet('192.168.10.77', 26);
    expect(subnet.networkAddress, '192.168.10.64');
    expect(subnet.broadcastAddress, '192.168.10.127');
    expect(subnet.subnetMask, '255.255.255.192');
  });
  test('10.0.5.120/16', () {
    final subnet = Ipv4Subnet('10.0.5.120', 16);
    expect(subnet.networkAddress, '10.0.0.0');
    expect(subnet.broadcastAddress, '10.0.255.255');
    expect(subnet.subnetMask, '255.255.0.0');
  });
  test('/32 is a host route without broadcast', () {
    final subnet = Ipv4Subnet('192.168.1.104', 32);
    expect(subnet.networkAddress, '192.168.1.104');
    expect(subnet.subnetMask, '255.255.255.255');
    expect(subnet.broadcastAddress, isNull);
  });
  test('/31 is point-to-point without broadcast', () {
    final subnet = Ipv4Subnet('10.0.0.3', 31);
    expect(subnet.networkAddress, '10.0.0.2');
    expect(subnet.broadcastAddress, isNull);
  });
  test('/0 handles all 32 address bits', () {
    final subnet = Ipv4Subnet('192.168.1.104', 0);
    expect(subnet.networkAddress, '0.0.0.0');
    expect(subnet.broadcastAddress, '255.255.255.255');
    expect(subnet.subnetMask, '0.0.0.0');
  });
  test('rejects malformed addresses and invalid prefixes', () {
    for (final address in [
      '',
      '1.2.3',
      '1.2.3.4.5',
      '256.1.1.1',
      '-1.2.3.4',
      '1.2.3.x',
      ' 1.2.3.4',
      '01.2.3.4',
      'example.local',
      '::1',
    ]) {
      expect(
        () => Ipv4Subnet(address, 24),
        throwsFormatException,
        reason: address,
      );
    }
    expect(() => Ipv4Subnet('1.2.3.4', -1), throwsArgumentError);
    expect(() => Ipv4Subnet('1.2.3.4', 33), throwsArgumentError);
  });
}
