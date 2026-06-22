import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/gen/pigeon/carp_movesense_connection_event_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dk/carp/carp_movesense_flutter/gen/PigeonCarpMovesenseConnectionEventApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dk.carp.carp_movesense_flutter',
      errorClassName: 'CarpMovesenseConnectionEventFlutterError',
    ),
    swiftOut:
        'ios/carp_movesense_flutter/Sources/carp_movesense_flutter/gen/PigeonCarpMovesenseConnectionEventApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'CarpMovesenseConnectionEventPigeonError',
    ),
    dartPackageName: 'carp_movesense_flutter',
  ),
)
class NativeConnectionEvent {
  NativeConnectionEvent({
    required this.type,
    this.address,
    this.serial,
    this.error,
  });

  String type;
  String? address;
  String? serial;
  String? error;
}

@FlutterApi()
abstract class CarpMovesenseConnectionFlutterApi {
  void onConnectionEvent(NativeConnectionEvent event);
}
