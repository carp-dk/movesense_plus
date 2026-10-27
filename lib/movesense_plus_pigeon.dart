import 'src/internal/pigeon_event_router.dart';
import 'src/movesense_models.dart';
import 'src/gen/pigeon/movesense_connection_host_api.g.dart' as connection;
import 'src/gen/pigeon/movesense_request_host_api.g.dart' as request;
import 'src/gen/pigeon/movesense_scan_host_api.g.dart' as scan;
import 'src/gen/pigeon/movesense_subscription_control_api.g.dart' as subscription_control;
import 'src/gen/pigeon/movesense_subscription_host_api.g.dart' as subscription;
import 'movesense_plus_platform_interface.dart';

/// Small abstraction over generated Pigeon host calls.
///
/// Tests can replace this gateway without exposing generated classes to the
/// public plugin API.
abstract interface class MovesenseHostGateway {
  Future<void> setScanEnabled(bool enabled);

  Future<void> setConnection(String address, bool connect);

  Future<void> sendRequest(int requestId, MdsRequestMethod method, String uri, String contract);

  Future<void> subscribe(int requestId, int subscriptionId, String uri, String contract);

  Future<void> unsubscribe(int subscriptionId);
}

/// Default [MovesenseHostGateway] backed by generated Pigeon channels.
class PigeonMovesenseHostGateway implements MovesenseHostGateway {
  PigeonMovesenseHostGateway({
    scan.MovesenseScanHostApi? scanApi,
    connection.MovesenseConnectionHostApi? connectionApi,
    request.MovesenseRequestHostApi? requestApi,
    subscription.MovesenseSubscriptionHostApi? subscriptionApi,
    subscription_control.MovesenseSubscriptionControlHostApi? subscriptionControlApi,
  }) : _scanApi = scanApi ?? scan.MovesenseScanHostApi(),
       _connectionApi = connectionApi ?? connection.MovesenseConnectionHostApi(),
       _requestApi = requestApi ?? request.MovesenseRequestHostApi(),
       _subscriptionApi = subscriptionApi ?? subscription.MovesenseSubscriptionHostApi(),
       _subscriptionControlApi = subscriptionControlApi ?? subscription_control.MovesenseSubscriptionControlHostApi();

  final scan.MovesenseScanHostApi _scanApi;
  final connection.MovesenseConnectionHostApi _connectionApi;
  final request.MovesenseRequestHostApi _requestApi;
  final subscription.MovesenseSubscriptionHostApi _subscriptionApi;
  final subscription_control.MovesenseSubscriptionControlHostApi _subscriptionControlApi;

  @override
  Future<void> setScanEnabled(bool enabled) {
    return _scanApi.setScanEnabled(enabled);
  }

  @override
  Future<void> setConnection(String address, bool connect) {
    return _connectionApi.setConnection(connection.NativeConnectionCommand(address: address, connect: connect));
  }

  @override
  Future<void> sendRequest(int requestId, MdsRequestMethod method, String uri, String contract) {
    return _requestApi.sendRequest(request.NativeMdsRequest(requestId: requestId, method: method.nativeName, uri: uri, contract: contract));
  }

  @override
  Future<void> subscribe(int requestId, int subscriptionId, String uri, String contract) {
    return _subscriptionApi.subscribe(
      subscription.NativeMdsSubscription(requestId: requestId, subscriptionId: subscriptionId, uri: uri, contract: contract),
    );
  }

  @override
  Future<void> unsubscribe(int subscriptionId) {
    return _subscriptionControlApi.unsubscribe(subscriptionId);
  }
}

/// Platform implementation that routes calls through Pigeon.
class PigeonMovesense extends MovesensePlatform {
  PigeonMovesense({MovesenseHostGateway? gateway, PigeonEventRouter? router})
    : _gateway = gateway ?? PigeonMovesenseHostGateway(),
      _router = router ?? PigeonEventRouter.instance {
    _router.attach();
  }

  final MovesenseHostGateway _gateway;
  final PigeonEventRouter _router;

  @override
  Stream<MovesenseScanResult> get scanResults => _router.scanResults;

  @override
  Stream<MovesenseConnectionEvent> get connectionEvents {
    return _router.connectionEvents;
  }

  @override
  Future<void> startScan() => _gateway.setScanEnabled(true);

  @override
  Future<void> stopScan() => _gateway.setScanEnabled(false);

  @override
  Future<void> connect(String address) {
    return _gateway.setConnection(address, true);
  }

  @override
  Future<void> disconnect(String address) {
    return _gateway.setConnection(address, false);
  }

  @override
  Future<MdsResponse> request(MdsRequestMethod method, String uri, String contract) {
    final pending = _router.registerRequest();
    _gateway.sendRequest(pending.id, method, uri, contract).catchError((Object error) => _router.failRequestStart(pending.id, error));
    return pending.future;
  }

  @override
  int subscribe(
    String uri,
    String contract, {
    MdsSuccessCallback? onSubscribe,
    MdsErrorCallback? onSubscribeError,
    required MdsNotificationCallback onNotification,
    MdsErrorCallback? onSubscriptionError,
  }) {
    final registered = _router.registerSubscription(
      SubscriptionCallbacks(
        onSubscribe: onSubscribe,
        onSubscribeError: onSubscribeError,
        onNotification: onNotification,
        onSubscriptionError: onSubscriptionError,
      ),
    );
    _gateway
        .subscribe(registered.requestId, registered.subscriptionId, uri, contract)
        .catchError((Object error) => _router.failSubscriptionStart(registered.subscriptionId, error));
    return registered.subscriptionId;
  }

  @override
  Future<void> unsubscribe(int subscriptionId) {
    _router.removeSubscription(subscriptionId);
    return _gateway.unsubscribe(subscriptionId);
  }
}
