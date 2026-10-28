import 'dart:async';

import '../movesense_plus_platform_interface.dart';
import 'movesense_device.dart';
import 'movesense_models.dart';

/// Entry point for Movesense BLE discovery and MDS operations.
///
/// Scanning yields [MovesenseDevice] objects that carry the typed device API
/// (connection status, device info, battery, sensor streams). The raw
/// [request] and [subscribe] methods reach any other MDS resource.
///
/// Pigeon DTOs stay behind [MovesensePlatform] so generator changes do not leak
/// into consuming apps.
class Movesense {
  /// Creates a client that uses [platform], or the default platform implementation.
  Movesense({MovesensePlatform? platform}) : _platform = platform ?? MovesensePlatform.instance;

  final MovesensePlatform _platform;

  /// Devices found while scanning.
  ///
  /// Each event is a [MovesenseDevice] bound to this client. The same peripheral
  /// is reported again every time an advertisement is received.
  Stream<MovesenseDevice> get scanResults {
    return _platform.scanResults.map((result) => MovesenseDevice(address: result.address, name: result.name, movesense: this));
  }

  /// Stream of connection lifecycle events for all devices.
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

  /// Connects to a Movesense peripheral by MAC address (Android) or UUID (Apple).
  Future<void> connect(String address) {
    return _platform.connect(address);
  }

  /// Disconnects from a Movesense peripheral by MAC address (Android) or UUID (Apple).
  Future<void> disconnect(String address) {
    return _platform.disconnect(address);
  }

  /// Sends one REST-style MDS request and completes with the response body.
  ///
  /// [uri] must include the `suunto://` prefix and the device serial, see
  /// [Mds.createRequestUri]. Fails with an [MdsError] on MDS errors.
  Future<MdsResponse> request(MdsRequestMethod method, String uri, {String contract = '{}'}) {
    return _platform.request(method, uri, contract);
  }

  /// Subscribes to an MDS resource and emits raw JSON notification bodies.
  ///
  /// [uri] is the device serial followed by the resource, see
  /// [Mds.createSubscriptionUri]. The returned stream is single-subscription;
  /// cancelling it unsubscribes from the resource.
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
