import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/gen/pigeon/carp_movesense_scan_device_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dk/carp/carp_movesense_flutter/gen/PigeonCarpMovesenseScanDeviceApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dk.carp.carp_movesense_flutter',
      errorClassName: 'CarpMovesenseScanDeviceFlutterError',
    ),
    swiftOut:
        'ios/carp_movesense_flutter/Sources/carp_movesense_flutter/gen/PigeonCarpMovesenseScanDeviceApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'CarpMovesenseScanDevicePigeonError',
    ),
    dartPackageName: 'carp_movesense_flutter',
  ),
)
class NativeScanDevice {
  NativeScanDevice({this.name, required this.address});

  String? name;
  String address;
}

@FlutterApi()
abstract class CarpMovesenseScanDeviceFlutterApi {
  void onScanDevice(NativeScanDevice device);
}
