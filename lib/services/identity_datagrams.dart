import 'dart:async';
import 'dart:io';
import '../models/network_info.dart';
import 'network_discovery_service.dart';

class IdentityPacket {
  const IdentityPacket(this.data, this.address, this.port);
  final List<int> data;
  final String address;
  final int port;
}

abstract interface class IdentityDatagrams {
  Future<void> exchange({
    required NetworkInfo network,
    required String destination,
    required int port,
    required List<int> request,
    required Duration duration,
    required ScanCancellation cancellation,
    required bool Function(IdentityPacket) onPacket,
    int hops = 1,
  });
}

/// Bound to the captured local address. Replies are unicast: no multicast
/// membership or Android reception lock is needed. Every path closes the socket.
class LocalIdentityDatagrams implements IdentityDatagrams {
  const LocalIdentityDatagrams();
  @override
  Future<void> exchange({
    required NetworkInfo network,
    required String destination,
    required int port,
    required List<int> request,
    required Duration duration,
    required ScanCancellation cancellation,
    required bool Function(IdentityPacket) onPacket,
    int hops = 1,
  }) async {
    if (cancellation.isCancelled) return;
    final done = Completer<void>();
    RawDatagramSocket? socket;
    StreamSubscription<RawSocketEvent>? subscription;
    var finished = false;
    void finish() {
      if (finished) return;
      finished = true;
      socket?.close();
      if (!done.isCompleted) done.complete();
    }

    cancellation.addListener(finish);
    final deadline = Timer(duration, finish);
    var packets = 0;
    // A late bind is closed, even when cancellation won the race before binding.
    unawaited(() async {
      try {
        final opened = await RawDatagramSocket.bind(
          network.localIpAddress!,
          0,
          reuseAddress: false,
        );
        socket = opened;
        if (done.isCompleted || cancellation.isCancelled) {
          opened.close();
          return;
        }
        opened.setRawOption(
          RawSocketOption(
            RawSocketOption.levelIPv4,
            RawSocketOption.IPv4MulticastInterface,
            InternetAddress(network.localIpAddress!).rawAddress,
          ),
        );
        opened.multicastHops = hops;
        opened.multicastLoopback = false;
        opened.writeEventsEnabled = false;
        subscription = opened.listen(
          (event) {
            if (event != RawSocketEvent.read ||
                done.isCompleted ||
                cancellation.isCancelled) {
              return;
            }
            for (var n = 0; n < 16; n++) {
              final packet = opened.receive();
              if (packet == null) break;
              if (++packets > 128) {
                finish();
                break;
              }
              if (packet.data.length <= 32768 &&
                  onPacket(
                    IdentityPacket(
                      packet.data,
                      packet.address.address,
                      packet.port,
                    ),
                  )) {
                finish();
                break;
              }
            }
          },
          onError: (Object error) {
            if (!done.isCompleted) done.completeError(error);
            finish();
          },
          onDone: finish,
        );
        if (opened.send(request, InternetAddress(destination), port) !=
            request.length) {
          throw const SocketException('Identity query could not be sent');
        }
      } catch (error, stack) {
        if (!done.isCompleted) done.completeError(error, stack);
        finish();
      }
    }());
    try {
      await done.future;
    } finally {
      deadline.cancel();
      cancellation.removeListener(finish);
      finish();
      await subscription?.cancel();
    }
  }
}
