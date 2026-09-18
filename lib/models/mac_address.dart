/// A unicast EUI-48 observation, not a permanent device identity.
class MacAddress {
  const MacAddress._(this.value, this.isLocallyAdministered);
  final String value;
  final bool isLocallyAdministered;

  static MacAddress? parse(String? input) {
    if (input == null) return null;
    final value = input.trim().toUpperCase();
    if (!RegExp(r'^(?:[0-9A-F]{2}:){5}[0-9A-F]{2}$').hasMatch(value) &&
        !RegExp(r'^(?:[0-9A-F]{2}-){5}[0-9A-F]{2}$').hasMatch(value)) {
      return null;
    }
    final normalized = value.replaceAll('-', ':');
    final first = int.parse(normalized.substring(0, 2), radix: 16);
    if (normalized == '00:00:00:00:00:00' ||
        normalized == '02:00:00:00:00:00' || // Android redaction placeholder.
        first & 1 != 0) {
      return null; // Multicast includes broadcast.
    }
    return MacAddress._(normalized, first & 2 != 0);
  }
}
