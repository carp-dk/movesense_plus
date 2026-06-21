import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'carp_movesense_flutter_pigeon.dart';

abstract class CarpMovesenseFlutterPlatform extends PlatformInterface {
  /// Constructs a CarpMovesenseFlutterPlatform.
  CarpMovesenseFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static CarpMovesenseFlutterPlatform _instance = PigeonCarpMovesenseFlutter();

  /// The default instance of [CarpMovesenseFlutterPlatform] to use.
  ///
  /// Defaults to the Pigeon-backed host API implementation.
  static CarpMovesenseFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CarpMovesenseFlutterPlatform] when
  /// they register themselves.
  static set instance(CarpMovesenseFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
