import 'dart:convert';

/// Bounded DNS wire reader, shared by NBSTAT and LLMNR. Compression loops and
/// truncated fields are rejected, never retried or followed off-packet.
class DnsWire {
  DnsWire(this.bytes);
  final List<int> bytes;
  int offset = 0;
  void need(int n) {
    if (n < 0 || offset + n > bytes.length) {
      throw const FormatException('Truncated packet');
    }
  }

  int u16() {
    need(2);
    final n = (bytes[offset] << 8) | bytes[offset + 1];
    offset += 2;
    return n;
  }

  void skip(int n) {
    need(n);
    offset += n;
  }

  String name() {
    var p = offset, jumped = false, length = 0;
    final labels = <String>[], seen = <int>{};
    while (true) {
      if (p >= bytes.length || !seen.add(p) || seen.length > 128) {
        throw const FormatException('Invalid name');
      }
      final size = bytes[p++];
      if (size == 0) {
        if (!jumped) offset = p;
        return labels.join('.');
      }
      if (size & 0xc0 == 0xc0) {
        if (p >= bytes.length) throw const FormatException('Truncated pointer');
        final target = ((size & 63) << 8) | bytes[p++];
        if (!jumped) offset = p;
        jumped = true;
        p = target;
        continue;
      }
      if (size > 63 || p + size > bytes.length || (length += size + 1) > 255) {
        throw const FormatException('Invalid label');
      }
      labels.add(ascii.decode(bytes.sublist(p, p + size)));
      p += size;
      if (!jumped) offset = p;
    }
  }

  static List<int> word(int n) => [(n >> 8) & 255, n & 255];
  static List<int> encodeName(String name) => [
    for (final label in name.split('.')) ...[
      label.length,
      ...ascii.encode(label),
    ],
    0,
  ];
  static List<int> query(int id, String name, int type) => [
    ...word(id),
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
    ...encodeName(name),
    ...word(type),
    0,
    1,
  ];
}
