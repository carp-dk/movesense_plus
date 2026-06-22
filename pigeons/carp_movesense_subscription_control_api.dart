import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut:
        'lib/src/gen/pigeon/carp_movesense_subscription_control_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dk/carp/carp_movesense_flutter/gen/PigeonCarpMovesenseSubscriptionControlApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dk.carp.carp_movesense_flutter',
      errorClassName: 'CarpMovesenseSubscriptionControlFlutterError',
    ),
    swiftOut:
        'ios/carp_movesense_flutter/Sources/carp_movesense_flutter/gen/PigeonCarpMovesenseSubscriptionControlApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'CarpMovesenseSubscriptionControlPigeonError',
    ),
    dartPackageName: 'carp_movesense_flutter',
  ),
)
@HostApi()
abstract class CarpMovesenseSubscriptionControlHostApi {
  void unsubscribe(int subscriptionId);
}
