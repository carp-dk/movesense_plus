import 'dart:async';

import '../movesense_models.dart';
import '../gen/pigeon/movesense_connection_event_api.g.dart' as connection;
import '../gen/pigeon/movesense_request_event_api.g.dart' as request;
import '../gen/pigeon/movesense_scan_device_api.g.dart' as scan_device;
import '../gen/pigeon/movesense_scan_error_api.g.dart' as scan_error;
import '../gen/pigeon/movesense_subscription_event_api.g.dart'
    as subscription;

class PendingMdsRequest {
  PendingMdsRequest(this.id, this.future);

  final int id;
  final Future<MdsResponse> future;
}

class RegisteredSubscription {
  RegisteredSubscription(this.requestId, this.subscriptionId);

  final int requestId;
  final int subscriptionId;
}

class SubscriptionCallbacks {
  const SubscriptionCallbacks({
    this.onSubscribe,
    this.onSubscribeError,
    required this.onNotification,
    this.onSubscriptionError,
  });

  final MdsSuccessCallback? onSubscribe;
  final MdsErrorCallback? onSubscribeError;
  final MdsNotificationCallback onNotification;
  final MdsErrorCallback? onSubscriptionError;
}

/// Routes typed native callbacks into Dart streams and pending operations.
class PigeonEventRouter {
  PigeonEventRouter._();

  static final PigeonEventRouter instance = PigeonEventRouter._();

  final _scanController = StreamController<MovesenseScanResult>.broadcast();
  final _connectionController =
      StreamController<MovesenseConnectionEvent>.broadcast();
  final _requests = <int, Completer<MdsResponse>>{};
  final _subscriptions = <int, SubscriptionCallbacks>{};

  int _nextRequestId = 0;
  int _nextSubscriptionId = 0;
  bool _attached = false;

  Stream<MovesenseScanResult> get scanResults => _scanController.stream;

  Stream<MovesenseConnectionEvent> get connectionEvents {
    return _connectionController.stream;
  }

  void attach() {
    if (_attached) return;
    scan_device.MovesenseScanDeviceFlutterApi.setUp(_ScanDeviceApi(this));
    scan_error.MovesenseScanErrorFlutterApi.setUp(_ScanErrorApi(this));
    connection.MovesenseConnectionFlutterApi.setUp(_ConnectionApi(this));
    request.MovesenseRequestFlutterApi.setUp(_RequestApi(this));
    subscription.MovesenseSubscriptionFlutterApi.setUp(
      _SubscriptionApi(this),
    );
    _attached = true;
  }

  PendingMdsRequest registerRequest() {
    final id = ++_nextRequestId;
    final completer = Completer<MdsResponse>();
    _requests[id] = completer;
    return PendingMdsRequest(id, completer.future);
  }

  RegisteredSubscription registerSubscription(SubscriptionCallbacks callbacks) {
    final requestId = ++_nextRequestId;
    final subscriptionId = ++_nextSubscriptionId;
    _subscriptions[subscriptionId] = callbacks;
    return RegisteredSubscription(requestId, subscriptionId);
  }

  void removeSubscription(int subscriptionId) {
    _subscriptions.remove(subscriptionId);
  }

  void failRequestStart(int requestId, Object error) {
    final completer = _requests.remove(requestId);
    completer?.completeError(MdsError(0, error.toString()));
  }

  void failSubscriptionStart(int subscriptionId, Object error) {
    final callbacks = _subscriptions.remove(subscriptionId);
    callbacks?.onSubscribeError?.call(MdsError(0, error.toString()));
  }
}

class _ScanDeviceApi implements scan_device.MovesenseScanDeviceFlutterApi {
  _ScanDeviceApi(this.router);

  final PigeonEventRouter router;

  @override
  void onScanDevice(scan_device.NativeScanDevice device) {
    router._scanController.add(
      MovesenseScanResult(name: device.name, address: device.address),
    );
  }
}

class _ScanErrorApi implements scan_error.MovesenseScanErrorFlutterApi {
  _ScanErrorApi(this.router);

  final PigeonEventRouter router;

  @override
  void onScanError(scan_error.NativeScanError error) {
    router._scanController.addError(MdsError(error.code, error.message));
  }
}

class _ConnectionApi implements connection.MovesenseConnectionFlutterApi {
  _ConnectionApi(this.router);

  final PigeonEventRouter router;

  @override
  void onConnectionEvent(connection.NativeConnectionEvent event) {
    router._connectionController.add(
      MovesenseConnectionEvent(
        type: _connectionType(event.type),
        address: event.address,
        serial: event.serial,
        error: event.error,
      ),
    );
  }
}

class _RequestApi implements request.MovesenseRequestFlutterApi {
  _RequestApi(this.router);

  final PigeonEventRouter router;

  @override
  void onRequestEvent(request.NativeMdsRequestEvent event) {
    final completer = router._requests.remove(event.requestId);
    if (completer == null) return;
    if (event.success) {
      completer.complete(
        MdsResponse(body: event.body, statusCode: event.statusCode),
      );
    } else {
      completer.completeError(MdsError(event.statusCode, event.error));
    }
  }
}

class _SubscriptionApi
    implements subscription.MovesenseSubscriptionFlutterApi {
  _SubscriptionApi(this.router);

  final PigeonEventRouter router;

  @override
  void onSubscriptionEvent(subscription.NativeMdsSubscriptionEvent event) {
    final callbacks = router._subscriptions[event.subscriptionId];
    if (callbacks == null) return;
    switch (event.type) {
      case 'subscribed':
        callbacks.onSubscribe?.call(
          MdsResponse(body: event.body, statusCode: event.statusCode),
        );
      case 'subscribeError':
        router._subscriptions.remove(event.subscriptionId);
        callbacks.onSubscribeError?.call(
          MdsError(event.statusCode, event.error),
        );
      case 'notification':
        callbacks.onNotification(event.body);
      case 'error':
        callbacks.onSubscriptionError?.call(
          MdsError(event.statusCode, event.error),
        );
      default:
        callbacks.onSubscriptionError?.call(MdsError(0, event.error));
    }
  }
}

MovesenseConnectionEventType _connectionType(String type) {
  return switch (type) {
    'bleConnected' => MovesenseConnectionEventType.bleConnected,
    'connected' => MovesenseConnectionEventType.connected,
    'disconnected' => MovesenseConnectionEventType.disconnected,
    'error' => MovesenseConnectionEventType.error,
    _ => MovesenseConnectionEventType.error,
  };
}
