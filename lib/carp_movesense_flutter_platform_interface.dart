import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'carp_movesense_flutter_pigeon.dart';
import 'src/movesense_models.dart';

abstract class CarpMovesenseFlutterPlatform extends PlatformInterface {
  /// Constructs a CarpMovesenseFlutterPlatform.
  CarpMovesenseFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static CarpMovesenseFlutterPlatform? _instance;

  /// The default instance of [CarpMovesenseFlutterPlatform] to use.
  ///
  /// Defaults to the Pigeon-backed host API implementation.
  static CarpMovesenseFlutterPlatform get instance {
    return _instance ??= PigeonCarpMovesenseFlutter();
  }

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CarpMovesenseFlutterPlatform] when
  /// they register themselves.
  static set instance(CarpMovesenseFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream<MovesenseDevice> get scanResults {
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
