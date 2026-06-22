import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/gen/pigeon/carp_movesense_scan_error_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dk/carp/carp_movesense_flutter/gen/PigeonCarpMovesenseScanErrorApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dk.carp.carp_movesense_flutter',
      errorClassName: 'CarpMovesenseScanErrorFlutterError',
    ),
    swiftOut:
        'ios/carp_movesense_flutter/Sources/carp_movesense_flutter/gen/PigeonCarpMovesenseScanErrorApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'CarpMovesenseScanErrorPigeonError',
    ),
    dartPackageName: 'carp_movesense_flutter',
  ),
)
class NativeScanError {
  NativeScanError({required this.code, required this.message});

  int code;
  String message;
}

@FlutterApi()
abstract class CarpMovesenseScanErrorFlutterApi {
  void onScanError(NativeScanError error);
}
