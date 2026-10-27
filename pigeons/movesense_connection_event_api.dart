import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/gen/pigeon/movesense_connection_event_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dk/carp/movesense_plus/gen/PigeonMovesenseConnectionEventApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dk.carp.movesense_plus',
      errorClassName: 'MovesenseConnectionEventFlutterError',
    ),
    swiftOut:
        'ios/movesense_plus/Sources/movesense_plus/gen/PigeonMovesenseConnectionEventApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'MovesenseConnectionEventPigeonError',
    ),
    dartPackageName: 'movesense_plus',
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
abstract class MovesenseConnectionFlutterApi {
  void onConnectionEvent(NativeConnectionEvent event);
}
