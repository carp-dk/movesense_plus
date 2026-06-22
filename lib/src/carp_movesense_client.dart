import 'dart:async';

import '../carp_movesense_flutter_platform_interface.dart';
import 'movesense_models.dart';

/// Public Dart client for Movesense BLE discovery and MDS operations.
///
/// The client exposes package-owned Dart types. Pigeon DTOs stay behind the
/// platform interface so generator changes do not leak into consuming apps.
class CarpMovesenseFlutter {
  CarpMovesenseFlutter({CarpMovesenseFlutterPlatform? platform}) : _platform = platform ?? CarpMovesenseFlutterPlatform.instance;

  final CarpMovesenseFlutterPlatform _platform;

  /// Stream of devices found while scanning.
  Stream<MovesenseDevice> get scanResults => _platform.scanResults;

  /// Stream of connection lifecycle events.
  Stream<MovesenseConnectionEvent> get connectionEvents {
    return _platform.connectionEvents;
  }

  /// Starts BLE scanning for peripherals advertising Movesense services.
  Future<void> startScan() {
    return _platform.startScan();
  }

  /// Stops BLE scanning.
  Future<void> stopScan() {
    return _platform.stopScan();
  }

  /// Connects to a Movesense peripheral by MAC address or UUID.
  Future<void> connect(String address) {
    return _platform.connect(address);
  }

  /// Disconnects from a Movesense peripheral by MAC address or UUID.
  Future<void> disconnect(String address) {
    return _platform.disconnect(address);
  }

  /// Sends one REST-style MDS request and completes with the response body.
  Future<MdsResponse> request(MdsRequestMethod method, String uri, {String contract = '{}'}) {
    return _platform.request(method, uri, contract);
  }

  /// Subscribes to an MDS resource and emits raw JSON notification bodies.
  Stream<String> subscribe(String uri, {String contract = '{}'}) {
    late final int subscriptionId;
    final controller = StreamController<String>();

    controller.onListen = () {
      subscriptionId = _platform.subscribe(
        uri,
        contract,
        onNotification: controller.add,
        onSubscriptionError: controller.addError,
        onSubscribeError: controller.addError,
      );
    };
    controller.onCancel = () => _platform.unsubscribe(subscriptionId);

    return controller.stream;
  }
}
