import 'dart:convert';
import '../models/mac_address.dart';
import '../models/network_device.dart';
import '../utils/identity_text.dart';
import 'dns_wire.dart';

class NbnsResult {
  const NbnsResult(this.name, this.workgroup, this.mac);
  final String name;
  final String? workgroup;
  final MacAddress? mac;
}

/// RFC 1002 NBSTAT: unicast wildcard Node Status query, not a name sweep.
class NbnsDiscoveryService {
  static const port = 137;
  static const timeout = Duration(milliseconds: 400);
  static bool relevant(NetworkDevice d) =>
      d.isOnline &&
      !d.isCurrentDevice &&
      !d.isGateway &&
      (d.openPorts.any((p) => p == 445 || p == 139) ||
          d.type == DeviceType.computer ||
          d.services.any(
            (s) => s.type == '_smb._tcp.' || s.type == '_workstation._tcp.',
          ) ||
          d.discoveryEvidence.any(
            (e) => RegExp(
              r'^TCP connection succeeded on port (445|139)$',
            ).hasMatch(e),
          ));
  static List<int> query(int id) {
    final name = [42, ...List.filled(15, 0)];
    final encoded = String.fromCharCodes([
      for (final b in name) ...[65 + (b >> 4), 65 + (b & 15)],
    ]);
    return DnsWire.query(id, encoded, 0x21);
  }

  static NbnsResult? parse(List<int> bytes, int id) {
    if (bytes.length > 4096) return null;
    try {
      final r = DnsWire(bytes);
      if (r.u16() != id) return null;
      final flags = r.u16();
      if (flags & 0x8000 == 0 || flags & 0x7a0f != 0) return null;
      final questions = r.u16(), answers = r.u16();
      r.skip(4);
      if (questions > 1 || answers < 1 || answers > 16) return null;
      for (var i = 0; i < questions; i++) {
        r.name();
        r.skip(4);
      }
      for (var i = 0; i < answers; i++) {
        r.name();
        final type = r.u16(), cls = r.u16();
        r.skip(4);
        final size = r.u16();
        r.need(size);
        final end = r.offset + size;
        if (type == 0x21 && cls == 1) {
          if (size < 47) return null;
          final count = bytes[r.offset++];
          if (count > 64 || size < 1 + 18 * count + 46) return null;
          String? name, group;
          for (var n = 0; n < count; n++) {
            final text = ascii
                .decode(bytes.sublist(r.offset, r.offset + 15))
                .trim();
            final suffix = bytes[r.offset + 15];
            r.skip(16);
            final flags = r.u16();
            if (flags & 0x1c00 != 0x0400 ||
                IdentityText.name(text) == null ||
                RegExp(r'[\x00-\x1f\x7f]').hasMatch(text)) {
              continue;
            }
            if (flags & 0x8000 != 0) {
              if (suffix == 0) group ??= text;
            } else if (suffix == 0 || suffix == 0x20) {
              name ??= text;
            }
          }
          final mac = MacAddress.parse(
            bytes
                .sublist(r.offset, r.offset + 6)
                .map((b) => b.toRadixString(16).padLeft(2, '0'))
                .join(':'),
          );
          return name == null ? null : NbnsResult(name, group, mac);
        }
        r.offset = end;
      }
    } on Exception {
      return null;
    }
    return null;
  }
}
