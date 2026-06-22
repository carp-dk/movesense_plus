import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/gen/pigeon/carp_movesense_subscription_host_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dk/carp/carp_movesense_flutter/gen/PigeonCarpMovesenseSubscriptionHostApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dk.carp.carp_movesense_flutter',
      errorClassName: 'CarpMovesenseSubscriptionHostFlutterError',
    ),
    swiftOut:
        'ios/carp_movesense_flutter/Sources/carp_movesense_flutter/gen/PigeonCarpMovesenseSubscriptionHostApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'CarpMovesenseSubscriptionHostPigeonError',
    ),
    dartPackageName: 'carp_movesense_flutter',
  ),
)
class NativeMdsSubscription {
  NativeMdsSubscription({
    required this.requestId,
    required this.subscriptionId,
    required this.uri,
    required this.contract,
  });

  int requestId;
  int subscriptionId;
  String uri;
  String contract;
}

@HostApi()
abstract class CarpMovesenseSubscriptionHostApi {
  void subscribe(NativeMdsSubscription subscription);
}
