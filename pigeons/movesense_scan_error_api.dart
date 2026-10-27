import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/gen/pigeon/movesense_scan_error_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dk/carp/movesense_plus/gen/PigeonMovesenseScanErrorApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dk.carp.movesense_plus',
      errorClassName: 'MovesenseScanErrorFlutterError',
    ),
    swiftOut:
        'ios/movesense_plus/Sources/movesense_plus/gen/PigeonMovesenseScanErrorApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'MovesenseScanErrorPigeonError',
    ),
    dartPackageName: 'movesense_plus',
  ),
)
class NativeScanError {
  NativeScanError({required this.code, required this.message});

  int code;
  String message;
}

@FlutterApi()
abstract class MovesenseScanErrorFlutterApi {
  void onScanError(NativeScanError error);
}
