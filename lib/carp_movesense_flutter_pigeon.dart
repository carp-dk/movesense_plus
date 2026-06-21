import 'src/pigeon/carp_movesense_api.g.dart';
import 'carp_movesense_flutter_platform_interface.dart';

/// Minimal abstraction over generated Pigeon host calls.
///
/// Generated Pigeon classes are intentionally kept out of the public API. This
/// adapter gives tests and future platform implementations a small seam to
/// replace the native transport without exposing generated-code churn to users.
abstract interface class CarpMovesenseHostGateway {
  /// Returns a human-readable platform version from the native host.
  Future<String> getPlatformVersion();
}

/// Default [CarpMovesenseHostGateway] backed by generated Pigeon channels.
class PigeonCarpMovesenseHostGateway implements CarpMovesenseHostGateway {
  PigeonCarpMovesenseHostGateway({CarpMovesenseHostApi? api})
    : _api = api ?? CarpMovesenseHostApi();

  final CarpMovesenseHostApi _api;

  @override
  Future<String> getPlatformVersion() {
    return _api.getPlatformVersion();
  }
}

/// Platform implementation that routes calls through Pigeon.
class PigeonCarpMovesenseFlutter extends CarpMovesenseFlutterPlatform {
  PigeonCarpMovesenseFlutter({CarpMovesenseHostGateway? gateway})
    : _gateway = gateway ?? PigeonCarpMovesenseHostGateway();

  final CarpMovesenseHostGateway _gateway;

  @override
  Future<String> getPlatformVersion() {
    return _gateway.getPlatformVersion();
  }
}
