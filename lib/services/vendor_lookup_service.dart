import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/mac_address.dart';

/// IEEE public MA-L registrations. No network access; one cached asset load.
class VendorLookupService {
  VendorLookupService({Future<String> Function()? loader})
    : _loader = loader ?? (() => rootBundle.loadString(assetPath));
  static const assetPath = 'assets/data/oui_vendors.json';
  static final bundled = VendorLookupService();
  final Future<String> Function() _loader;
  Future<void>? _loading;
  Map<String, String> _vendors = const {};
  int get prefixCount => _vendors.length;

  Future<void> loadBundledDatabase() => _loading ??= () async {
    _vendors = await compute(parse, await _loader());
  }();

  static Map<String, String> parse(String text) {
    final decoded = jsonDecode(text);
    if (decoded is! Map) throw const FormatException('Expected OUI map');
    return Map.unmodifiable({
      for (final entry in decoded.entries)
        if (entry.key is String &&
            entry.value is String &&
            RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(entry.key as String) &&
            (entry.value as String).trim().isNotEmpty)
          (entry.key as String).toUpperCase(): (entry.value as String).trim(),
    });
  }

  String? lookup(String? input) {
    final mac = MacAddress.parse(input);
    if (mac == null || mac.isLocallyAdministered) return null;
    final vendor = _vendors[mac.value.replaceAll(':', '').substring(0, 6)];
    // These blocks delegate smaller registrations, not a device manufacturer.
    if (vendor == 'IEEE Registration Authority' ||
        vendor?.toLowerCase() == 'private') {
      return null;
    }
    return vendor;
  }
}
