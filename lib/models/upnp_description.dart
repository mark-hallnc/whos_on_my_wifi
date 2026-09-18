import 'dart:convert';
import 'dart:io';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';
import '../models/network_info.dart';
import '../utils/ipv4_subnet.dart';

/// Immutable, bounded device-supplied data. URLs here are metadata, never actions.
class UpnpDescription {
  UpnpDescription(
    Map<String, String> fields,
    List<Map<String, String>> services,
  ) : fields = Map.unmodifiable(fields),
      services = List.unmodifiable(
        services.map(Map<String, String>.unmodifiable),
      );
  final Map<String, String> fields;
  final List<Map<String, String>> services;
  String? get friendlyName => fields['friendlyName'];
  String? get manufacturer => fields['manufacturer'];
  String? get modelName => fields['modelName'];
  String? get modelNumber => fields['modelNumber'];
  String? get modelDescription => fields['modelDescription'];
  String? get deviceType => fields['deviceType'];
  static const maxBytes = 256 * 1024;
  static const fieldNames = [
    'friendlyName',
    'manufacturer',
    'manufacturerURL',
    'modelDescription',
    'modelName',
    'modelNumber',
    'modelURL',
    'serialNumber',
    'UDN',
    'deviceType',
    'presentationURL',
  ];
  static const serviceFields = [
    'serviceType',
    'serviceId',
    'controlURL',
    'eventSubURL',
    'SCPDURL',
  ];

  static UpnpDescription? parse(List<int> bytes) {
    if (bytes.length > maxBytes) return null;
    try {
      final text = utf8.decode(bytes);
      // Reject all DTD/entity declarations before parsing. No entity resolver,
      // network loader, XInclude processor or endpoint execution is installed.
      final upper = text.toUpperCase();
      if (upper.contains('<!DOCTYPE') || upper.contains('<!ENTITY')) {
        return null;
      }
      var depth = 0;
      var nodes = 0;
      for (final event in parseEvents(text)) {
        if (++nodes > 8192) return null;
        if (event is XmlStartElementEvent &&
            !event.isSelfClosing &&
            ++depth > 32) {
          return null;
        }
        if (event is XmlEndElementEvent) depth--;
      }
      final document = XmlDocument.parse(text);
      final root = document.rootElement;
      if (root.name.local != 'root') return null;
      final device = root.childElements
          .where((e) => e.name.local == 'device')
          .firstOrNull;
      if (device == null) return null;
      Map<String, String> read(XmlElement element, List<String> names) => {
        for (final child in element.childElements)
          if (names.contains(child.name.local) &&
              child.innerText.trim().isNotEmpty)
            child.name.local: child.innerText.trim().substring(
              0,
              child.innerText.trim().length.clamp(0, 1024),
            ),
      };
      final services = <Map<String, String>>[];
      // Include embedded devices' service lists, but never borrow their identity.
      for (final list in device.descendantElements.where(
        (e) => e.name.local == 'serviceList',
      )) {
        for (final entry in list.childElements.where(
          (e) => e.name.local == 'service',
        )) {
          if (services.length >= 64) break;
          final fields = read(entry, serviceFields);
          if (fields.containsKey('serviceType')) services.add(fields);
        }
      }
      return UpnpDescription(read(device, fieldNames), services);
    } on XmlException {
      return null;
    } on FormatException {
      return null;
    }
  }
}

class SsdpAdvertisement {
  SsdpAdvertisement(this.address, Map<String, String> headers)
    : headers = Map.unmodifiable(headers);
  final String address;
  final Map<String, String> headers;
  String get identity =>
      '$address|${headers['usn']}|${headers['st']}|${headers['location']}';
  static const headerNames = {
    'location',
    'st',
    'usn',
    'server',
    'cache-control',
    'ext',
    'bootid.upnp.org',
    'configid.upnp.org',
  };
  static SsdpAdvertisement? parse(List<int> bytes, String sender) {
    if (bytes.length > 8192 || bytes.isEmpty) return null;
    final text = latin1.decode(bytes);
    if (text.contains('\u0000')) return null;
    final lines = text.split('\r\n');
    if (!RegExp(
      r'^HTTP/1\.[01] 200(?: .*|)$',
      caseSensitive: false,
    ).hasMatch(lines.first)) {
      return null;
    }
    if (!text.contains('\r\n\r\n')) return null;
    final headers = <String, String>{};
    for (final line in lines.skip(1)) {
      if (line.isEmpty) break;
      final colon = line.indexOf(':');
      if (colon <= 0 || line.startsWith(' ') || line.startsWith('\t')) {
        return null;
      }
      final key = line.substring(0, colon).trim().toLowerCase();
      if (!headerNames.contains(key)) continue;
      final value = line.substring(colon + 1).trim();
      if (value.length > 2048 || headers.containsKey(key)) return null;
      headers[key] = value;
    }
    if (!headers.containsKey('st') &&
        !headers.containsKey('usn') &&
        !headers.containsKey('location')) {
      return null;
    }
    return SsdpAdvertisement(sender, headers);
  }
}

/// Only canonical literal IPv4 on the captured LAN; no DNS or redirect escape.
class LocalDescriptionPolicy {
  LocalDescriptionPolicy(this.network);
  final NetworkInfo network;
  bool isLocal(String ip) {
    final local = network.localIpAddress;
    final prefix = network.ipv4PrefixLength;
    if (local == null || prefix == null) return false;
    try {
      final subnet = Ipv4Subnet(local, prefix);
      final target = Ipv4Subnet(ip, prefix);
      final parsed = InternetAddress.tryParse(ip);
      return parsed != null &&
          parsed.type == InternetAddressType.IPv4 &&
          !parsed.isLoopback &&
          !parsed.isMulticast &&
          ip != '0.0.0.0' &&
          target.networkAddress == subnet.networkAddress &&
          (prefix >= 31 ||
              (ip != subnet.networkAddress && ip != subnet.broadcastAddress));
    } on FormatException {
      return false;
    } on ArgumentError {
      return false;
    }
  }

  Uri? location(String? value, String sender) {
    if (value == null || value.length > 2048 || !isLocal(sender)) return null;
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.userInfo.isNotEmpty ||
        uri.hasFragment ||
        uri.host != sender ||
        !isLocal(uri.host) ||
        uri.port < 1 ||
        uri.port > 65535) {
      return null;
    }
    return uri;
  }
}
