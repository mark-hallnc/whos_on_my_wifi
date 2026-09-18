import 'dart:async';
import 'dart:io';
import '../models/network_info.dart';
import '../models/upnp_description.dart';
import 'network_discovery_service.dart';

class UpnpDescriptionFetcher {
  UpnpDescriptionFetcher({HttpClient Function()? clientFactory})
    : _clientFactory = clientFactory ?? HttpClient.new;
  static const connectionTimeout = Duration(milliseconds: 600);
  static const responseTimeout = Duration(milliseconds: 800);
  static const totalTimeout = Duration(milliseconds: 1800);
  final HttpClient Function() _clientFactory;

  Future<UpnpDescription?> fetch(
    Uri location,
    String sender,
    NetworkInfo network,
    ScanCancellation cancellation,
  ) async {
    if (cancellation.isCancelled ||
        LocalDescriptionPolicy(network).location(location.toString(), sender) ==
            null) {
      return null;
    }
    final client = _clientFactory();
    HttpClientRequest? request;
    final connections = <ConnectionTask<Socket>>[];
    var closed = false;
    void close() {
      closed = true;
      request?.abort();
      for (final task in connections) {
        task.cancel();
      }
      client.close(force: true);
    }

    cancellation.addListener(close);
    try {
      client.connectionTimeout = connectionTimeout;
      client.autoUncompress = false;
      client.findProxy = (_) => 'DIRECT';
      client.connectionFactory = (uri, _, _) async {
        if (closed) throw const SocketException('Discovery stopped');
        final task = await Socket.startConnect(
          InternetAddress(uri.host),
          uri.port,
          sourceAddress: network.localIpAddress,
        );
        connections.add(task);
        if (closed) task.cancel();
        return task;
      };
      return await (() async {
        request = await client.getUrl(location).timeout(connectionTimeout);
        if (closed) {
          request!.abort();
          return null;
        }
        request!.followRedirects = false;
        request!.maxRedirects = 0;
        request!.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
        final response = await request!.close().timeout(responseTimeout);
        // Reject every redirect, including same-LAN redirects; no second request.
        if (closed ||
            response.statusCode != HttpStatus.ok ||
            response.contentLength > UpnpDescription.maxBytes) {
          return null;
        }
        final encoding = response.headers.value(
          HttpHeaders.contentEncodingHeader,
        );
        if (encoding != null && encoding.toLowerCase() != 'identity') {
          return null;
        }
        final bytes = <int>[];
        await for (final chunk in response.timeout(responseTimeout)) {
          if (closed ||
              bytes.length + chunk.length > UpnpDescription.maxBytes) {
            return null;
          }
          bytes.addAll(chunk);
        }
        if (closed) return null;
        return UpnpDescription.parse(bytes);
      })().timeout(totalTimeout);
    } on Exception {
      return null;
    } finally {
      close();
      cancellation.removeListener(close);
    }
  }
}
