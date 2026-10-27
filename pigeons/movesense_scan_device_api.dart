import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/gen/pigeon/movesense_scan_device_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dk/carp/movesense_plus/gen/PigeonMovesenseScanDeviceApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dk.carp.movesense_plus',
      errorClassName: 'MovesenseScanDeviceFlutterError',
    ),
    swiftOut:
        'ios/movesense_plus/Sources/movesense_plus/gen/PigeonMovesenseScanDeviceApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'MovesenseScanDevicePigeonError',
    ),
    dartPackageName: 'movesense_plus',
  ),
)
class NativeScanDevice {
  NativeScanDevice({this.name, required this.address});

  String? name;
  String address;
}

@FlutterApi()
abstract class MovesenseScanDeviceFlutterApi {
  void onScanDevice(NativeScanDevice device);
}
