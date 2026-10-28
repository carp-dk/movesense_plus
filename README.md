# Movesense Plus

[![pub package](https://img.shields.io/pub/v/movesense_plus.svg)](https://pub.dev/packages/movesense_plus)

A Flutter plugin for the [Movesense](https://www.movesense.com/) family of sensors (Movesense MD, Active HR+ and HR2), made by [CARP](https://carp.dk).

The plugin bundles the native Movesense MDS libraries for Android and iOS and talks to them through typed [Pigeon](https://pub.dev/packages/pigeon) channels. On top of the raw MDS API it provides a strongly typed device API for the most commonly used parts of the [Movesense API](https://www.movesense.com/docs/esw/api_reference/).

## Features

* scan for Movesense devices (and stop scanning again)
* connect and disconnect, with a connection status per device
* device info, battery level and system states
* typed streams of sensor data:
  * heart rate and R-R intervals
  * ECG
  * 9-axis IMU
  * temperature
  * state events (movement, connectors, tap, double tap, free fall)
* raw MDS `GET`, `PUT`, `POST` and `DELETE` requests and subscriptions to any resource
* `Mds` and `MdsAsync` compatibility classes for code written against [mdsflutter](https://pub.dev/packages/mdsflutter)

## Getting started

Add `movesense_plus` to your `pubspec.yaml`. No native setup is needed: the Movesense `mdslib` AAR (Android) and `MovesenseMDS.xcframework` (iOS) are bundled with the plugin.

Requirements: Dart 3.12 or later, Android `minSdk` 24, iOS 15.0.

### Permissions

The plugin does not request runtime permissions. Use the [permission_handler](https://pub.dev/packages/permission_handler) plugin to request Bluetooth scan and connect permissions on Android, see the example app.

* **Android**: the required `BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT` and legacy Bluetooth and location permissions are declared in the plugin manifest and merged into your app.
* **iOS**: add `NSBluetoothAlwaysUsageDescription` to your `Info.plist`. Add `bluetooth-central` to `UIBackgroundModes` if you want to keep streaming in the background.

### Upgrading from `movesense_plus` 1.x or `carp_movesense_flutter` 0.1.x

Version 2.0.0 is the Pigeon-based plugin previously published as `carp_movesense_flutter`, and replaces the `mdsflutter`-based 1.x releases. When upgrading from 1.x, remove the manual Movesense SDK setup from your app: the `pod 'Movesense', :git => ...` line in the iOS `Podfile`, and the vendored `android/libs/mdslib-*.aar` with its `flatDir` repository.

The API is new. The most common changes:

| 1.x | 2.0.0 |
|---|---|
| `Movesense().scan()`, `Movesense().devices` | `Movesense().startScan()`, `Movesense().scanResults` |
| `MovesenseDevice(address: ...)`, `connect()`, `hr`, `ecg`, ... | unchanged |
| `DeviceConnectionStatus` | `MovesenseDeviceStatus` |
| `DeviceBatteryLevel` | `MovesenseBatteryLevel` |
| `SystemStateComponent` | `MovesenseSystemState` |
| `MovesenseDeviceType.MD`, `HR_PLUS`, `HR2` | `MovesenseDeviceType.md`, `hrPlus`, `hr2` |
| `MovesenseHR.average` as `int` | `double`, plus the full `rrData` list |

Code written against `carp_movesense_flutter` only needs to rename `CarpMovesenseFlutter` to `Movesense` and the imports to `package:movesense_plus/movesense_plus.dart`.

## Usage

Import `package:movesense_plus/movesense_plus.dart`. `Movesense` is the entry point for scanning and raw MDS access, and `MovesenseDevice` is the typed API of one sensor.

### Scanning for devices

```dart
final movesense = Movesense();

movesense.scanResults.listen((device) {
  print('Discovered ${device.name} [${device.address}]');
});

await movesense.startScan();

// Stop scanning at some later point.
await movesense.stopScan();
```

### Connecting to a device

A `MovesenseDevice` comes from the scan, or can be created directly when the address is known:

```dart
final device = MovesenseDevice(address: '0C:8C:DC:1B:23:BF');

device.statusEvents.listen((status) {
  print('Connection status: ${status.name}');
});

await device.connect();
```

> **NOTE:** The `address` format is platform dependent:
>
> * On Android, the address is the Bluetooth MAC address (e.g. `0C:8C:DC:1B:23:BF`).
> * On iOS, the address is the UUID of the peripheral (e.g. `89BD8BF8-C9E7-0395-3B1D-119082516DDE`).

The connection status is available in `status` and emitted on the `statusEvents` stream. On connection the plugin fetches the device info and battery level, and `isConnected` becomes true.

### Device information, battery status and system states

Once connected:

* `deviceInfo` / `getDeviceInfo()` - the full [device info](https://www.movesense.com/docs/esw/api_reference/#info) as a `MovesenseDeviceInfo`.
* `deviceType` - the hardware variant (`md`, `hrPlus`, `hr2`), derived from the device info.
* `batteryLevel` / `getBatteryStatus()` - the [battery level](https://www.movesense.com/docs/esw/api_reference/#systemstates), which Movesense reports as `ok` or `low`.
* `getState(MovesenseSystemState)` - the current [system state](https://www.movesense.com/docs/esw/api_reference/#systemstates) of a component (movement, connectors, tap, double tap, free fall).

```dart
print('Product: ${device.deviceInfo?.productName}, serial: ${device.serial}');
print('Type: ${device.deviceType.name}, battery: ${device.batteryLevel.name}');

final connectors = await device.getState(MovesenseSystemState.connectors);
print('Strap: ${connectors?.state.name}');
```

### Streaming sensor data

The following streams are available on a connected device:

* `hr` - `MovesenseHR` with the average heart rate (bpm) and R-R intervals (ms), at 1 Hz.
* `ecg` - `MovesenseECG` with raw ECG samples, at 125 Hz.
* `imu` - `MovesenseIMU` with synchronized accelerometer, gyroscope and magnetometer samples, at 13 Hz.
* `temperature` - `MovesenseTemperature` in Kelvin (with a `celsius` getter). Movesense MD only.

```dart
final subscription = device.hr.listen((hr) {
  print('Heart rate: ${hr.average}, R-R: ${hr.rr} ms');
});

// Stop streaming.
await subscription.cancel();
```

Each stream opens an MDS subscription when listened to and closes it when the listener cancels. Listening before the device is connected emits a `StateError`.

### Streaming state change events

```dart
device.getStateEvents(MovesenseSystemState.tap).listen((state) {
  print('State: ${state.state.name} at ${state.timestamp}');
});
```

> **NOTE:** The Movesense firmware only allows [one state subscription at a time](https://github.com/petri-lipponen-movesense/mdsflutter/issues/15), and not all components are supported on all devices. Only the `connectors` and `tap` states have been confirmed on the Movesense MD and HR2.

### Raw MDS access

Any other [Movesense resource](https://www.movesense.com/docs/esw/api_reference/) can be reached with REST-style requests and subscriptions. On a connected device the serial is filled in for you:

```dart
// Turn the LED on.
await device.request(MdsRequestMethod.put, '/Component/Led', contract: '{"isOn": true}');

// Accelerometer at 52 Hz, as raw JSON notification bodies.
device.subscribe('/Meas/Acc/52').listen(print);

// ECG at 256 Hz, parsed with the typed model.
device.subscribe('/Meas/ECG/256').map((body) => MovesenseECG.fromMovesenseData(jsonDecode(body))).listen(print);
```

Without a `MovesenseDevice`, use the `Movesense` client with full URIs:

```dart
final response = await movesense.request(MdsRequestMethod.get, Mds.createRequestUri(serial, '/Info'));
print(response.body);

movesense.subscribe(Mds.createSubscriptionUri(serial, '/Meas/HR')).listen(print);
```

Requests fail with an `MdsError` carrying the MDS status code. Connection events for all devices are available on `movesense.connectionEvents`.

### mdsflutter compatibility

The static `Mds` and `MdsAsync` classes mirror the `mdsflutter` API (`Mds.connect`, `Mds.get`, `Mds.subscribe`, `MdsAsync.subscribe`, ...) so existing code can switch to this plugin by changing the import.

## Example app

The `example/` folder contains a tester app that exercises the whole API: scanning, connecting, sending requests, subscribing to resources and viewing the log.

| Scan | Device | Request | Subscriptions | Logs |
|:---:|:---:|:---:|:---:|:---:|
| <img src="images/01_scan.PNG" width="160"/> | <img src="images/02_device.PNG" width="160"/> | <img src="images/03_request.PNG" width="160"/> | <img src="images/04_subscriptions.PNG" width="160"/> | <img src="images/05_logs.PNG" width="160"/> |

## Contributing

Please file feature requests and bug reports as [issues](https://github.com/carp-dk/movesense_plus/issues). Pull requests are welcome.

### Architecture

* `lib/src/movesense_client.dart` - `Movesense`, the public client over the platform interface.
* `lib/src/movesense_device.dart` and `lib/src/movesense_data.dart` - the typed device API and data models.
* `lib/src/mds_compat.dart` - the `mdsflutter`-compatible `Mds` and `MdsAsync` facades.
* `lib/movesense_plus_platform_interface.dart` and `lib/movesense_plus_pigeon.dart` - the platform interface and its Pigeon-backed implementation. Pigeon DTOs never leak into the public API.

### Pigeon

Dart/native transport is generated with [Pigeon](https://pub.dev/packages/pigeon). The contracts live in `pigeons/` and are split by responsibility (`movesense_scan_*`, `movesense_connection_*`, `movesense_request_*`, `movesense_subscription_*`). After editing a contract, regenerate the bindings:

```sh
tool/generate_pigeon.sh
```

Generated code is written under `gen/` folders:

* `lib/src/gen/pigeon/`
* `android/src/main/kotlin/dk/carp/movesense_plus/gen/`
* `ios/movesense_plus/Sources/movesense_plus/gen/`
* `macos/movesense_plus/Sources/movesense_plus/gen/`

The original `mdsflutter` callback message schema is kept in `protos/movesense_mds.proto` for reference; the runtime uses Pigeon DTOs instead of protobuf byte arrays.

### Movesense SDKs

Android uses the vendored Movesense `mdslib` AAR under `android/vendor`. iOS uses the vendored `MovesenseMDS.xcframework` under `ios/movesense_plus/Vendor`, which can be rebuilt from the Movesense SDK with `tool/generate_movesense_mds_xcframework.sh` (the framework must be signed with a valid certificate, see the script). The compiled SDKs come from the [movesense-mobile-lib](https://bitbucket.org/movesense/movesense-mobile-lib/src/master/) repository.

macOS registers the same Pigeon channels but returns unsupported errors, because no macOS Movesense MDS binary is bundled.

## Credits

The native MDS bridging is based on [mdsflutter](https://github.com/tugberka/mdsflutter) and the improved fork at [petri-lipponen-movesense/mdsflutter](https://github.com/petri-lipponen-movesense/mdsflutter).

## License

This software is copyright (c) the [Copenhagen Research Platform](https://carp.dk/) at the [Technical University of Denmark](https://dtu.dk/) and is available 'as-is' under a [MIT license](LICENSE).
