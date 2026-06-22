import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/gen/pigeon/carp_movesense_scan_host_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dk/carp/carp_movesense_flutter/gen/PigeonCarpMovesenseScanHostApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dk.carp.carp_movesense_flutter',
      errorClassName: 'CarpMovesenseScanHostFlutterError',
    ),
    swiftOut:
        'ios/carp_movesense_flutter/Sources/carp_movesense_flutter/gen/PigeonCarpMovesenseScanHostApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'CarpMovesenseScanHostPigeonError',
    ),
    dartPackageName: 'carp_movesense_flutter',
  ),
)
@HostApi()
abstract class CarpMovesenseScanHostApi {
  void setScanEnabled(bool enabled);
}
