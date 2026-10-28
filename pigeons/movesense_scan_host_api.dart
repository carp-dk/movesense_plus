import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/gen/pigeon/movesense_scan_host_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dk/carp/movesense_plus/gen/PigeonMovesenseScanHostApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dk.carp.movesense_plus',
      errorClassName: 'MovesenseScanHostFlutterError',
    ),
    swiftOut:
        'ios/movesense_plus/Sources/movesense_plus/gen/PigeonMovesenseScanHostApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'MovesenseScanHostPigeonError',
    ),
    dartPackageName: 'movesense_plus',
  ),
)
@HostApi()
abstract class MovesenseScanHostApi {
  void setScanEnabled(bool enabled);
}
