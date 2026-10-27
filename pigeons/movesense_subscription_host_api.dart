import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/gen/pigeon/movesense_subscription_host_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dk/carp/movesense_plus/gen/PigeonMovesenseSubscriptionHostApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dk.carp.movesense_plus',
      errorClassName: 'MovesenseSubscriptionHostFlutterError',
    ),
    swiftOut:
        'ios/movesense_plus/Sources/movesense_plus/gen/PigeonMovesenseSubscriptionHostApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'MovesenseSubscriptionHostPigeonError',
    ),
    dartPackageName: 'movesense_plus',
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
abstract class MovesenseSubscriptionHostApi {
  void subscribe(NativeMdsSubscription subscription);
}
