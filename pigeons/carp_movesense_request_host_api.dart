import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/gen/pigeon/carp_movesense_request_host_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dk/carp/carp_movesense_flutter/gen/PigeonCarpMovesenseRequestHostApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dk.carp.carp_movesense_flutter',
      errorClassName: 'CarpMovesenseRequestHostFlutterError',
    ),
    swiftOut:
        'ios/carp_movesense_flutter/Sources/carp_movesense_flutter/gen/PigeonCarpMovesenseRequestHostApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'CarpMovesenseRequestHostPigeonError',
    ),
    dartPackageName: 'carp_movesense_flutter',
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
abstract class CarpMovesenseRequestHostApi {
  void sendRequest(NativeMdsRequest request);
}
