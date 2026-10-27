import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut:
        'lib/src/gen/pigeon/movesense_subscription_control_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dk/carp/movesense_plus/gen/PigeonMovesenseSubscriptionControlApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dk.carp.movesense_plus',
      errorClassName: 'MovesenseSubscriptionControlFlutterError',
    ),
    swiftOut:
        'ios/movesense_plus/Sources/movesense_plus/gen/PigeonMovesenseSubscriptionControlApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'MovesenseSubscriptionControlPigeonError',
    ),
    dartPackageName: 'movesense_plus',
  ),
)
@HostApi()
abstract class MovesenseSubscriptionControlHostApi {
  void unsubscribe(int subscriptionId);
}
