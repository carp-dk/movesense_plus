import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/gen/pigeon/carp_movesense_subscription_event_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dk/carp/carp_movesense_flutter/gen/PigeonCarpMovesenseSubscriptionEventApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dk.carp.carp_movesense_flutter',
      errorClassName: 'CarpMovesenseSubscriptionEventFlutterError',
    ),
    swiftOut:
        'ios/carp_movesense_flutter/Sources/carp_movesense_flutter/gen/PigeonCarpMovesenseSubscriptionEventApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'CarpMovesenseSubscriptionEventPigeonError',
    ),
    dartPackageName: 'carp_movesense_flutter',
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
abstract class CarpMovesenseSubscriptionFlutterApi {
  void onSubscriptionEvent(NativeMdsSubscriptionEvent event);
}
