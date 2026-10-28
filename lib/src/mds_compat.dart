import 'dart:async';
import 'dart:convert';

import '../movesense_plus_platform_interface.dart';
import 'movesense_client.dart';
import 'movesense_device.dart';
import 'movesense_models.dart';

const String _mdsPrefix = 'suunto://';

/// mdsflutter-compatible static API backed by the CARP Pigeon implementation.
class Mds {
  static final Movesense _client = Movesense();
  static final _connectionCallbacks = <String, _ConnectionCallbacks>{};
  static final _disconnecting = <String>{};

  static StreamSubscription<MovesenseDevice>? _scanSubscription;
  static StreamSubscription<MovesenseConnectionEvent>? _connectionSubscription;

  /// Starts scanning for Movesense BLE peripherals.
  static void startScan(void Function(String? name, String? address) onNewDeviceFound) {
    _scanSubscription?.cancel();
    _scanSubscription = _client.scanResults.listen((device) => onNewDeviceFound(device.name, device.address));
    unawaited(_client.startScan());
  }

  /// Stops the ongoing scan.
  static void stopScan() {
    unawaited(_scanSubscription?.cancel());
    _scanSubscription = null;
    unawaited(_client.stopScan());
  }

  /// Connects to a device by MAC address on Android or UUID on Apple platforms.
  static void connect(
    String address,
    void Function(String serial) onConnected,
    void Function() onDisconnected,
    void Function(String error) onConnectionError,
    void Function(String address)? onBleConnected,
  ) {
    _ensureConnectionListener();
    _connectionCallbacks[address] = _ConnectionCallbacks(
      onConnected: onConnected,
      onDisconnected: onDisconnected,
      onConnectionError: onConnectionError,
      onBleConnected: onBleConnected,
    );
    _client.connect(address).catchError((Object error) {
      _connectionCallbacks.remove(address);
      onConnectionError(_errorMessage(error));
    });
  }

  /// Disconnects from a device by MAC address on Android or UUID on Apple platforms.
  static void disconnect(String address) {
    _disconnecting.add(address);
    unawaited(_client.disconnect(address));
  }

  static void get(
    String uri,
    String contract,
    void Function(String data, int statusCode) onSuccess,
    void Function(String error, int statusCode) onError,
  ) {
    _request(MdsRequestMethod.get, uri, contract, onSuccess, onError);
  }

  static void put(
    String uri,
    String contract,
    void Function(String data, int statusCode) onSuccess,
    void Function(String error, int statusCode) onError,
  ) {
    _request(MdsRequestMethod.put, uri, contract, onSuccess, onError);
  }

  static void post(
    String uri,
    String contract,
    void Function(String data, int statusCode) onSuccess,
    void Function(String error, int statusCode) onError,
  ) {
    _request(MdsRequestMethod.post, uri, contract, onSuccess, onError);
  }

  static void del(
    String uri,
    String contract,
    void Function(String data, int statusCode) onSuccess,
    void Function(String error, int statusCode) onError,
  ) {
    _request(MdsRequestMethod.delete, uri, contract, onSuccess, onError);
  }

  /// Starts an MDS subscription and returns the Dart-side subscription id.
  static int subscribe(
    String uri,
    String contract,
    void Function(String data, int statusCode) onSuccess,
    void Function(String error, int statusCode) onError,
    void Function(String data) onNotification,
    void Function(String error, int statusCode) onSubscriptionError,
  ) {
    return MovesensePlatform.instance.subscribe(
      uri,
      contract,
      onSubscribe: (response) => onSuccess(response.body, response.statusCode),
      onSubscribeError: (error) => onError(error.error, error.status),
      onNotification: onNotification,
      onSubscriptionError: (error) => onSubscriptionError(error.error, error.status),
    );
  }

  /// Stops an MDS subscription returned by [subscribe].
  static void unsubscribe(int subscriptionId) {
    unawaited(MovesensePlatform.instance.unsubscribe(subscriptionId));
  }

  static String createRequestUri(String serial, String resource) {
    return _mdsPrefix + serial + resource;
  }

  static String createSubscriptionUri(String serial, String resource) {
    return serial + resource;
  }

  static void _request(
    MdsRequestMethod method,
    String uri,
    String contract,
    void Function(String data, int statusCode) onSuccess,
    void Function(String error, int statusCode) onError,
  ) {
    _client
        .request(method, uri, contract: contract)
        .then((response) {
          onSuccess(response.body, response.statusCode);
        })
        .catchError((Object error) {
          final mdsError = _asMdsError(error);
          onError(mdsError.error, mdsError.status);
        });
  }

  static void _ensureConnectionListener() {
    _connectionSubscription ??= _client.connectionEvents.listen((event) {
      final address = event.address;
      if (address == null) return;
      final callbacks = _connectionCallbacks[address];
      if (callbacks == null) return;
      switch (event.type) {
        case MovesenseConnectionEventType.bleConnected:
          callbacks.onBleConnected?.call(address);
        case MovesenseConnectionEventType.connected:
          callbacks.onConnected(event.serial ?? '');
        case MovesenseConnectionEventType.disconnected:
          callbacks.onDisconnected();
          if (_disconnecting.remove(address)) {
            _connectionCallbacks.remove(address);
          }
        case MovesenseConnectionEventType.error:
          _connectionCallbacks.remove(address);
          callbacks.onConnectionError(event.error ?? 'Connection failed.');
      }
    });
  }
}

/// Future and Stream wrappers matching the mdsflutter convenience API.
class MdsAsync {
  static void startScan(void Function(String? name, String? address) onNewDeviceFound) {
    Mds.startScan(onNewDeviceFound);
  }

  static void stopScan() {
    Mds.stopScan();
  }

  static Future<dynamic> get(String uri, String contract) {
    return _asyncRequest(MdsRequestMethod.get, uri, contract, keepBodyOnNoContent: true);
  }

  static Future<dynamic> put(String uri, String contract) {
    return _asyncRequest(MdsRequestMethod.put, uri, contract);
  }

  static Future<dynamic> post(String uri, String contract) {
    return _asyncRequest(MdsRequestMethod.post, uri, contract);
  }

  static Future<dynamic> del(String uri, String contract) {
    return _asyncRequest(MdsRequestMethod.delete, uri, contract);
  }

  static Stream<dynamic> subscribe(String uri, String contract) {
    return Mds._client.subscribe(uri, contract: contract).map(jsonDecode);
  }
}

class _ConnectionCallbacks {
  const _ConnectionCallbacks({
    required this.onConnected,
    required this.onDisconnected,
    required this.onConnectionError,
    this.onBleConnected,
  });

  final void Function(String serial) onConnected;
  final void Function() onDisconnected;
  final void Function(String error) onConnectionError;
  final void Function(String address)? onBleConnected;
}

Future<dynamic> _asyncRequest(MdsRequestMethod method, String uri, String contract, {bool keepBodyOnNoContent = false}) async {
  try {
    final response = await Mds._client.request(method, uri, contract: contract);
    final decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    if (decoded is Map && decoded.containsKey('Content')) {
      return decoded['Content'];
    }
    return keepBodyOnNoContent ? decoded : null;
  } on MdsError {
    rethrow;
  } catch (error) {
    throw _asMdsError(error);
  }
}

MdsError _asMdsError(Object error) {
  return error is MdsError ? error : MdsError(0, error.toString());
}

String _errorMessage(Object error) {
  return error is MdsError ? error.error : error.toString();
}
