import 'dart:async';
import 'package:flutter/services.dart';
import '../models/network_info.dart';
import 'network_discovery_service.dart';
import 'service_device_merger.dart';

abstract interface class LocalServiceDiscovery {
  Future<List<String>> discover({
    required NetworkInfo network,
    required ScanCancellation cancellation,
    required Future<void> Function(ResolvedLocalService) onService,
    required Future<void> Function() verifyNetwork,
  });
}

/// One foreground scan; native and Dart deadlines both bound its lifetime.
class AndroidNsdDiscoveryService implements LocalServiceDiscovery {
  AndroidNsdDiscoveryService({
    this.channel = const MethodChannel('whos_on_my_wifi/nsd'),
  });
  static const discoveryWindow = Duration(seconds: 4);
  static const networkCheckInterval = Duration(milliseconds: 400);
  final MethodChannel channel;
  static int _nextId = 0;
  bool _active = false;

  @override
  Future<List<String>> discover({
    required NetworkInfo network,
    required ScanCancellation cancellation,
    required Future<void> Function(ResolvedLocalService) onService,
    required Future<void> Function() verifyNetwork,
  }) async {
    if (_active) return ['Local service discovery is already active.'];
    if (cancellation.isCancelled) return [];
    _active = true;
    final id = ++_nextId;
    final done = Completer<void>();
    final warnings = <String>{};
    var accepting = true;
    var queued = 0;
    Future<void> processing = Future.value();
    Future<void>? stopping;
    Timer? deadline;
    Timer? monitor;
    Future<void>? monitoring;
    Future<void> stop() => stopping ??= () async {
      try {
        await channel.invokeMethod<void>('stop', {'id': id});
      } on MissingPluginException {
        /* Tests and non-Android platforms. */
      } on PlatformException {
        warnings.add('Android could not confirm NSD cleanup.');
      }
    }();
    void finish() {
      accepting = false;
      if (!done.isCompleted) done.complete();
    }

    void cancel() {
      finish();
      unawaited(stop());
    }

    cancellation.addListener(cancel);
    try {
      channel.setMethodCallHandler((call) async {
        if (!accepting || cancellation.isCancelled || call.arguments is! Map) {
          return;
        }
        final raw = call.arguments as Map;
        if (raw['id'] != id) return;
        if (call.method == 'done') {
          finish();
          return;
        }
        if (call.method == 'cancelled') {
          final reason =
              raw['message'] as String? ?? 'Local service discovery stopped.';
          if (reason == 'Network changed. Scan stopped.') {
            try {
              await verifyNetwork();
            } catch (_) {
              /* Keep the native reason. */
            }
          }
          cancellation.cancel(reason);
          return;
        }
        if (call.method == 'warning') {
          warnings.add(
            'Some local services could not be discovered or resolved.',
          );
          return;
        }
        if (call.method != 'service' || queued >= 128) return;
        final service = ResolvedLocalService.fromPlatform(raw);
        if (service == null) return;
        queued++;
        processing = processing
            .then((_) async {
              if (cancellation.isCancelled) return;
              await verifyNetwork();
              if (!cancellation.isCancelled) await onService(service);
            })
            .catchError((Object error) {
              cancellation.cancel('Network access unavailable. Scan stopped.');
            });
      });
      await channel.invokeMethod<void>('start', {
        'id': id,
        'networkId': network.id,
        'types': ResolvedLocalService.serviceTypes,
      });
      if (cancellation.isCancelled) return warnings.toList();
      deadline = Timer(
        discoveryWindow + const Duration(milliseconds: 500),
        finish,
      );
      monitor = Timer.periodic(networkCheckInterval, (_) {
        if (monitoring != null || !accepting || cancellation.isCancelled) {
          return;
        }
        monitoring = () async {
          try {
            await verifyNetwork();
          } catch (_) {
            cancellation.cancel('Network access unavailable. Scan stopped.');
          }
        }().whenComplete(() => monitoring = null);
      });
      await done.future;
    } on MissingPluginException {
      warnings.add('Android NSD is unavailable on this platform.');
    } on PlatformException catch (error) {
      if (error.code == 'permission_denied') {
        cancellation.cancel(
          'Local network permission unavailable. Scan stopped.',
        );
      } else if (error.code == 'network_changed') {
        cancellation.cancel('Network changed. Scan stopped.');
      } else {
        warnings.add(
          'Local service discovery is unavailable; TCP results are retained.',
        );
      }
    } finally {
      accepting = false;
      deadline?.cancel();
      monitor?.cancel();
      cancellation.removeListener(cancel);
      await stop();
      await monitoring;
      await processing;
      channel.setMethodCallHandler(null);
      _active = false;
    }
    return warnings.toList();
  }
}
