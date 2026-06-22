import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/gen/pigeon/carp_movesense_request_event_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dk/carp/carp_movesense_flutter/gen/PigeonCarpMovesenseRequestEventApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dk.carp.carp_movesense_flutter',
      errorClassName: 'CarpMovesenseRequestEventFlutterError',
    ),
    swiftOut:
        'ios/carp_movesense_flutter/Sources/carp_movesense_flutter/gen/PigeonCarpMovesenseRequestEventApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'CarpMovesenseRequestEventPigeonError',
    ),
    dartPackageName: 'carp_movesense_flutter',
  ),
)
class NativeMdsRequestEvent {
  NativeMdsRequestEvent({
    required this.requestId,
    required this.success,
    required this.statusCode,
    required this.body,
    required this.error,
  });

  int requestId;
  bool success;
  int statusCode;
  String body;
  String error;
}

@FlutterApi()
abstract class CarpMovesenseRequestFlutterApi {
  void onRequestEvent(NativeMdsRequestEvent event);
}
