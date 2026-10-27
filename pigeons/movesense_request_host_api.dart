import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/gen/pigeon/movesense_request_host_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dk/carp/movesense_plus/gen/PigeonMovesenseRequestHostApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dk.carp.movesense_plus',
      errorClassName: 'MovesenseRequestHostFlutterError',
    ),
    swiftOut:
        'ios/movesense_plus/Sources/movesense_plus/gen/PigeonMovesenseRequestHostApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'MovesenseRequestHostPigeonError',
    ),
    dartPackageName: 'movesense_plus',
  ),
)
class NativeMdsRequest {
  NativeMdsRequest({
    required this.requestId,
    required this.method,
    required this.uri,
    required this.contract,
  });

  int requestId;
  String method;
  String uri;
  String contract;
}

@HostApi()
abstract class MovesenseRequestHostApi {
  void sendRequest(NativeMdsRequest request);
}
