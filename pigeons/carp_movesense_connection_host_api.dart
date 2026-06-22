import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/gen/pigeon/carp_movesense_connection_host_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dk/carp/carp_movesense_flutter/gen/PigeonCarpMovesenseConnectionHostApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dk.carp.carp_movesense_flutter',
      errorClassName: 'CarpMovesenseConnectionHostFlutterError',
    ),
    swiftOut:
        'ios/carp_movesense_flutter/Sources/carp_movesense_flutter/gen/PigeonCarpMovesenseConnectionHostApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'CarpMovesenseConnectionHostPigeonError',
    ),
    dartPackageName: 'carp_movesense_flutter',
  ),
)
class NativeConnectionCommand {
  NativeConnectionCommand({required this.address, required this.connect});

  String address;
  bool connect;
}

@HostApi()
abstract class CarpMovesenseConnectionHostApi {
  void setConnection(NativeConnectionCommand command);
}
