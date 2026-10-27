import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/gen/pigeon/movesense_connection_host_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dk/carp/movesense_plus/gen/PigeonMovesenseConnectionHostApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dk.carp.movesense_plus',
      errorClassName: 'MovesenseConnectionHostFlutterError',
    ),
    swiftOut:
        'ios/movesense_plus/Sources/movesense_plus/gen/PigeonMovesenseConnectionHostApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'MovesenseConnectionHostPigeonError',
    ),
    dartPackageName: 'movesense_plus',
  ),
)
class NativeConnectionCommand {
  NativeConnectionCommand({required this.address, required this.connect});

  String address;
  bool connect;
}

@HostApi()
abstract class MovesenseConnectionHostApi {
  void setConnection(NativeConnectionCommand command);
}
