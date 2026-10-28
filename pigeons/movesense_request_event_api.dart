import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/gen/pigeon/movesense_request_event_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dk/carp/movesense_plus/gen/PigeonMovesenseRequestEventApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dk.carp.movesense_plus',
      errorClassName: 'MovesenseRequestEventFlutterError',
    ),
    swiftOut:
        'ios/movesense_plus/Sources/movesense_plus/gen/PigeonMovesenseRequestEventApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'MovesenseRequestEventPigeonError',
    ),
    dartPackageName: 'movesense_plus',
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
abstract class MovesenseRequestFlutterApi {
  void onRequestEvent(NativeMdsRequestEvent event);
}
