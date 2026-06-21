import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/carp_movesense_api.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/dk/carp/carp_movesense_flutter/PigeonCarpMovesenseApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'dk.carp.carp_movesense_flutter'),
    swiftOut:
        'ios/carp_movesense_flutter/Sources/carp_movesense_flutter/PigeonCarpMovesenseApi.g.swift',
    swiftOptions: SwiftOptions(),
    dartPackageName: 'carp_movesense_flutter',
  ),
)
/// Host-side API implemented by the native plugin code.
///
/// Keep this file focused on transport contracts: use explicit DTO classes for
/// values crossing the platform boundary, and keep Dart-only convenience types
/// in `lib/`. Generated files must be regenerated after every edit here.
@HostApi()
abstract class CarpMovesenseHostApi {
  /// Returns the host platform version.
  ///
  /// This intentionally small method is the first generated round trip. It
  /// keeps the Pigeon setup testable before the Movesense-specific API surface
  /// is expanded with scan, connection, request, and subscription contracts.
  String getPlatformVersion();
}
