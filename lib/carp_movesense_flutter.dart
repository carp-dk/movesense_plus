import 'carp_movesense_flutter_platform_interface.dart';

/// Dart entry point for the CARP Movesense Flutter plugin.
///
/// Public methods in this class should stay independent from Pigeon-generated
/// types. Convert generated DTOs into stable package types here as the
/// Movesense API grows.
class CarpMovesenseFlutter {
  /// Returns the host platform version through the native plugin.
  Future<String> getPlatformVersion() {
    return CarpMovesenseFlutterPlatform.instance.getPlatformVersion();
  }
}
