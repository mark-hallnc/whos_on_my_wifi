/// Pure IPv4 arithmetic; never resolves a hostname or sends network traffic.
class Ipv4Subnet {
  Ipv4Subnet(String address, this.prefixLength) {
    if (prefixLength < 0 || prefixLength > 32) {
      throw ArgumentError.value(prefixLength, 'prefixLength', 'Must be 0–32');
    }
    final parts = address.split('.');
    if (parts.length != 4 ||
        parts.any(
          (part) =>
              !RegExp(r'^(0|[1-9][0-9]{0,2})$').hasMatch(part) ||
              (int.tryParse(part) ?? 256) > 255,
        )) {
      throw FormatException('Invalid IPv4 address', address);
    }
    final value = parts.fold<int>(
      0,
      (result, part) => (result << 8) | int.parse(part),
    );
    final mask = prefixLength == 0
        ? 0
        : (0xffffffff << (32 - prefixLength)) & 0xffffffff;
    subnetMask = _format(mask);
    networkAddress = _format(value & mask);
    // /31 is point-to-point and /32 is a host route: neither has broadcast.
    broadcastAddress = prefixLength >= 31
        ? null
        : _format((value & mask) | (0xffffffff ^ mask));
  }

  final int prefixLength;
  late final String subnetMask;
  late final String networkAddress;
  late final String? broadcastAddress;
  String get cidr => '$networkAddress/$prefixLength';

  static String _format(int value) =>
      [24, 16, 8, 0].map((shift) => (value >> shift) & 255).join('.');
}
