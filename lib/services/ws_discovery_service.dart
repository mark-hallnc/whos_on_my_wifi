import 'dart:convert';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';
import '../models/network_info.dart';
import '../models/upnp_description.dart';

class WsDiscoveryResult {
  WsDiscoveryResult({
    required this.ip,
    required this.endpoint,
    required this.types,
    required this.scopes,
    required this.xaddrs,
  });
  final String ip, endpoint;

  /// Expanded QName, so arbitrary namespace prefixes cannot imply a device type.
  final List<String> types, scopes, xaddrs;
}

class WsDiscoveryService {
  static const port = 3702;
  static const multicast = '239.255.255.250';
  static const duration = Duration(seconds: 2);
  static const maxBytes = 32768;
  static const discovery = 'http://schemas.xmlsoap.org/ws/2005/04/discovery';
  static const addressing = 'http://schemas.xmlsoap.org/ws/2004/08/addressing';
  static const soap = 'http://www.w3.org/2003/05/soap-envelope';
  // WS-Discovery April 2005 is the interoperable Windows/ONVIF profile.
  static String probe(String id) =>
      '<?xml version="1.0" encoding="UTF-8"?>'
      '<s:Envelope xmlns:s="$soap" xmlns:a="$addressing" xmlns:d="$discovery">'
      '<s:Header><a:MessageID>$id</a:MessageID><a:To>urn:schemas-xmlsoap-org:ws:2005:04:discovery</a:To>'
      '<a:Action>$discovery/Probe</a:Action><a:ReplyTo><a:Address>$addressing/role/anonymous</a:Address></a:ReplyTo>'
      '</s:Header><s:Body><d:Probe/></s:Body></s:Envelope>';
  static XmlElement? child(XmlElement parent, String local, String ns) => parent
      .childElements
      .where((e) => e.name.local == local && e.name.namespaceUri == ns)
      .firstOrNull;
  static String? namespace(XmlElement node, String prefix) {
    XmlNode? current = node;
    while (current != null) {
      if (current is XmlElement) {
        for (final attr in current.attributes) {
          if (attr.name.qualified ==
              (prefix.isEmpty ? 'xmlns' : 'xmlns:$prefix')) {
            return attr.value;
          }
        }
      }
      current = current.parent;
    }
    return null;
  }

  static List<WsDiscoveryResult> parse(
    List<int> bytes,
    String sender,
    NetworkInfo network,
    String id,
  ) {
    final policy = LocalDescriptionPolicy(network);
    if (bytes.length > maxBytes || !policy.isLocal(sender)) return [];
    try {
      final text = utf8.decode(bytes);
      if (text.toUpperCase().contains('<!DOCTYPE') ||
          text.toUpperCase().contains('<!ENTITY')) {
        return [];
      }
      var depth = 0, count = 0;
      for (final event in parseEvents(text)) {
        if (++count > 2048) return [];
        if (event is XmlStartElementEvent &&
            !event.isSelfClosing &&
            ++depth > 24) {
          return [];
        }
        if (event is XmlEndElementEvent) depth--;
      }
      final root = XmlDocument.parse(text).rootElement;
      if (root.name.local != 'Envelope' || root.name.namespaceUri != soap) {
        return [];
      }
      final header = child(root, 'Header', soap),
          body = child(root, 'Body', soap);
      if (header == null ||
          body == null ||
          child(header, 'RelatesTo', addressing)?.innerText.trim() != id ||
          child(header, 'Action', addressing)?.innerText.trim() !=
              '$discovery/ProbeMatches') {
        return [];
      }
      final matches = child(body, 'ProbeMatches', discovery);
      if (matches == null) return [];
      final results = <WsDiscoveryResult>[];
      for (final match in matches.childElements.take(16)) {
        if (match.name.local != 'ProbeMatch' ||
            match.name.namespaceUri != discovery) {
          continue;
        }
        final epr = child(match, 'EndpointReference', addressing);
        final endpoint = epr == null
            ? ''
            : child(epr, 'Address', addressing)?.innerText.trim() ?? '';
        if (endpoint.length > 256) continue;
        final typesNode = child(match, 'Types', discovery);
        final types = <String>[];
        for (final qname
            in (typesNode?.innerText.trim() ?? '')
                .split(RegExp(r'\s+'))
                .take(16)) {
          final parts = qname.split(':');
          if (parts.length > 2 || qname.isEmpty || typesNode == null) continue;
          final uri = namespace(
            typesNode,
            parts.length == 2 ? parts.first : '',
          );
          if (uri != null && uri.length < 256 && parts.last.length < 128) {
            types.add('{$uri}${parts.last}');
          }
        }
        final scopes =
            (child(match, 'Scopes', discovery)?.innerText.trim() ?? '')
                .split(RegExp(r'\s+'))
                .where((v) => v.isNotEmpty && v.length <= 512)
                .take(16)
                .toList();
        final raw = (child(match, 'XAddrs', discovery)?.innerText.trim() ?? '')
            .split(RegExp(r'\s+'))
            .where((v) => v.isNotEmpty)
            .toList();
        final urls = raw
            .where(
              (v) => v.length <= 1024 && policy.location(v, sender) != null,
            )
            .take(8)
            .toList();
        // Keep responses without XAddrs; reject those advertising only external,
        // ambiguous DNS, or another host's endpoints. Never fetch any endpoint.
        if (raw.isNotEmpty && urls.isEmpty) continue;
        results.add(
          WsDiscoveryResult(
            ip: sender,
            endpoint: endpoint,
            types: types,
            scopes: scopes,
            xaddrs: urls,
          ),
        );
      }
      return results;
    } on Exception {
      return [];
    }
  }
}
