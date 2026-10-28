import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'movesense_plus_pigeon.dart';
import 'src/movesense_models.dart';

abstract class MovesensePlatform extends PlatformInterface {
  /// Constructs a MovesensePlatform.
  MovesensePlatform() : super(token: _token);

  static final Object _token = Object();

  static MovesensePlatform? _instance;

  /// The default instance of [MovesensePlatform] to use.
  ///
  /// Defaults to the Pigeon-backed host API implementation.
  static MovesensePlatform get instance {
    return _instance ??= PigeonMovesense();
  }

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MovesensePlatform] when
  /// they register themselves.
  static set instance(MovesensePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream<MovesenseScanResult> get scanResults {
    throw UnimplementedError('scanResults has not been implemented.');
  }

  Stream<MovesenseConnectionEvent> get connectionEvents {
    throw UnimplementedError('connectionEvents has not been implemented.');
  }

  Future<void> startScan() {
    throw UnimplementedError('startScan() has not been implemented.');
  }

  Future<void> stopScan() {
    throw UnimplementedError('stopScan() has not been implemented.');
  }

  Future<void> connect(String address) {
    throw UnimplementedError('connect() has not been implemented.');
  }

  Future<void> disconnect(String address) {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  Future<MdsResponse> request(MdsRequestMethod method, String uri, String contract) {
    throw UnimplementedError('request() has not been implemented.');
  }

  int subscribe(
    String uri,
    String contract, {
    MdsSuccessCallback? onSubscribe,
    MdsErrorCallback? onSubscribeError,
    required MdsNotificationCallback onNotification,
    MdsErrorCallback? onSubscriptionError,
  }) {
    throw UnimplementedError('subscribe() has not been implemented.');
  }

  Future<void> unsubscribe(int subscriptionId) {
    throw UnimplementedError('unsubscribe() has not been implemented.');
  }
}
