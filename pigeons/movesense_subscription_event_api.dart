import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/gen/pigeon/movesense_subscription_event_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dk/carp/movesense_plus/gen/PigeonMovesenseSubscriptionEventApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dk.carp.movesense_plus',
      errorClassName: 'MovesenseSubscriptionEventFlutterError',
    ),
    swiftOut:
        'ios/movesense_plus/Sources/movesense_plus/gen/PigeonMovesenseSubscriptionEventApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'MovesenseSubscriptionEventPigeonError',
    ),
    dartPackageName: 'movesense_plus',
  ),
)
class NativeMdsSubscriptionEvent {
  NativeMdsSubscriptionEvent({
    required this.type,
    required this.requestId,
    required this.subscriptionId,
    required this.statusCode,
    required this.body,
    required this.error,
  });

  String type;
  int requestId;
  int subscriptionId;
  int statusCode;
  String body;
  String error;
}

@FlutterApi()
abstract class MovesenseSubscriptionFlutterApi {
  void onSubscriptionEvent(NativeMdsSubscriptionEvent event);
}
