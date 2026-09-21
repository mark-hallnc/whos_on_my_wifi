import '../utils/identity_text.dart';
import 'dns_wire.dart';

/// RFC 4795 sections 2.3/2.4: PTR is legal; unicast UDP is NOT. This sender
/// cannot inspect ICMP errors and uses the permitted multicast UDP PTR form,
/// scoped to a few known-live addresses. It never calls system reverse DNS.
class LlmnrResolver {
  static const port = 5355;
  static const multicast = '224.0.0.252';
  static const timeout = Duration(milliseconds: 400);
  static String reverse(String ip) =>
      '${ip.split('.').reversed.join('.')}.in-addr.arpa';
  static List<int> query(String ip, int id) =>
      DnsWire.query(id, reverse(ip), 12);
  static String? parse(List<int> bytes, String ip, int id) {
    if (bytes.length > 4096) return null;
    try {
      final r = DnsWire(bytes);
      if (r.u16() != id) return null;
      final flags = r.u16();
      // Reject truncated, tentative, conflicting, error and non-query opcodes.
      if (flags != 0x8000 || r.u16() != 1) return null;
      final answers = r.u16();
      r.skip(4);
      if (answers < 1 ||
          answers > 16 ||
          r.name().toLowerCase() != reverse(ip) ||
          r.u16() != 12 ||
          r.u16() != 1) {
        return null;
      }
      for (var i = 0; i < answers; i++) {
        final owner = r.name();
        final type = r.u16(), cls = r.u16();
        r.skip(4);
        final size = r.u16();
        r.need(size);
        final end = r.offset + size;
        if (owner.toLowerCase() == reverse(ip) && type == 12 && cls == 1) {
          final name = r.name();
          if (r.offset != end || RegExp(r'[\x00-\x20\x7f]').hasMatch(name)) {
            return null;
          }
          return IdentityText.name(name);
        }
        r.offset = end;
      }
    } on Exception {
      return null;
    }
    return null;
  }
}
