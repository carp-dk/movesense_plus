# Movesense Plus

<p>
  <a href="https://carp.dk"><img align="right" width="166" height="70" src="images/carp-x-dtu-logo.svg" alt="CARP x DTU"></a>
  <a href="https://pub.dev/packages/movesense_plus"><img src="https://img.shields.io/pub/v/movesense_plus?logo=dart&amp;logoColor=white&amp;label=pub&amp;color=0175C2" alt="pub version"></a>
  <a href="https://pub.dev/packages/movesense_plus/score"><img src="https://img.shields.io/pub/likes/movesense_plus" alt="pub likes"></a>
  <a href="https://pub.dev/packages/movesense_plus/score"><img src="https://img.shields.io/pub/dm/movesense_plus" alt="pub monthly downloads"></a>
  <br>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-plugin-02569B?logo=flutter&amp;logoColor=white" alt="Flutter plugin"></a>
  <a href="#supported-devices-and-platforms"><img src="https://img.shields.io/badge/Android-API%2024%2B-3DDC84?logo=android&amp;logoColor=white" alt="Android API 24+"></a>
  <a href="#supported-devices-and-platforms"><img src="https://img.shields.io/badge/iOS-15.0%2B-000000?logo=apple&amp;logoColor=white" alt="iOS 15.0+"></a>
  <a href="https://www.movesense.com/"><img src="https://img.shields.io/badge/Movesense-MD%20%7C%20HR%2B%20%7C%20HR2-E4002B?logo=bluetooth&amp;logoColor=white" alt="Movesense MD, HR+ and HR2"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/carp-dk/movesense_plus?color=blue" alt="License: MIT"></a>
  <br clear="right">
</p>

A Flutter plugin for [Movesense](https://www.movesense.com/) sensors (Movesense MD, Active HR+ and HR2), made by the [Copenhagen Research Platform (CARP)](https://carp.dk) at the [Technical University of Denmark (DTU)](https://dtu.dk).

The plugin bundles the native Movesense MDS libraries for Android and iOS, so there is no native SDK to set up. On top of raw access to the full [Movesense API](https://www.movesense.com/docs/esw/api_reference/), it provides a strongly typed device API for the parts you use most: connection status, device info, battery and sensor streams.

**Contents:** [Features](#features) · [Platforms](#supported-devices-and-platforms) · [Installation](#installation) · [Quick start](#quick-start) · [Usage](#usage) · [Upgrading](#upgrading-to-200) · [Example app](#example-app) · [Contributing](#contributing) · [Credits](#credits) · [License](#license)

## Features

* **Scanning**: find Movesense devices, with start and stop
* **Connection management**: connect and disconnect, with a connection status per device
* **Device status**: device info, battery level and system states
* **Typed sensor streams**: heart rate and R-R intervals, ECG, 9-axis IMU, temperature, and state events (movement, connectors, tap, double tap, free fall)
* **Raw MDS access**: `GET`, `PUT`, `POST` and `DELETE` requests and subscriptions to any resource
* **`mdsflutter` compatibility**: `Mds` and `MdsAsync` classes for code written against [mdsflutter](https://pub.dev/packages/mdsflutter)
* **No native setup**: the Movesense `mdslib` AAR (Android) and `MovesenseMDS.xcframework` (iOS) ship with the plugin

## Supported devices and platforms

| Platform | Supported | Minimum version | Notes |
|---|:---:|---|---|
| Android | ✅ | API 24 (Android 7.0) | Use a physical device. The Movesense library has no `x86_64` build. |
| iOS | ✅ | iOS 15.0 | Use a physical device. Bluetooth is not available in the Simulator. |
| macOS | ❌ | | The plugin registers, but scanning, connecting, requests and subscriptions fail with an "unsupported" error. |

**Sensors:** Movesense MD, Movesense Active HR+ and Movesense HR2. They are reported as `MovesenseDeviceType.md`, `hrPlus` and `hr2`.

## Installation

```sh
flutter pub add movesense_plus
```

The plugin requires Dart 3.12 or later.

### Android

The plugin's manifest declares the Bluetooth and location permissions, and they are merged into your app:

* `BLUETOOTH_SCAN` and `BLUETOOTH_CONNECT` on Android 12 and later.
* `BLUETOOTH`, `BLUETOOTH_ADMIN` and `ACCESS_FINE_LOCATION` on Android 11 and lower.

You still have to request `BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT` and, on Android 11 and lower, `ACCESS_FINE_LOCATION` at runtime. See [Runtime permissions](#runtime-permissions).

The Movesense library ships native code for `arm64-v8a`, `armeabi-v7a` and 32-bit `x86`, but not for `x86_64`. To keep `x86_64` out of your build, restrict the ABIs in `defaultConfig` as the [example app](example/android/app/build.gradle.kts) does:

```kotlin
ndk {
    abiFilters.addAll(listOf("arm64-v8a", "armeabi-v7a"))
}
```

### iOS

The plugin builds with both CocoaPods and Swift Package Manager. Add a Bluetooth usage description to your app's `Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses Bluetooth to connect to Movesense sensors.</string>
```

The plugin sets up Bluetooth when the app starts, so iOS asks for Bluetooth access at launch. To keep streaming in the background, add `bluetooth-central` to `UIBackgroundModes`.

### Runtime permissions

The plugin does not request runtime permissions itself:

* **Android:** use [permission_handler](https://pub.dev/packages/permission_handler) to request the Bluetooth scan and connect permissions before scanning. On Android 11 and lower, also request the location permission (`Permission.locationWhenInUse`). The example app requests the scan and connect permissions in [`movesense_permission_service.dart`](example/lib/src/permissions/movesense_permission_service.dart), but not location.
* **iOS:** the system shows the Bluetooth prompt itself.

## Quick start

Once the [runtime permissions](#runtime-permissions) are granted, this finds the first sensor, connects to it and prints its heart rate:

```dart
import 'package:movesense_plus/movesense_plus.dart';

Future<void> streamHeartRate() async {
  final movesense = Movesense();

  // 1. Scan, and take the first Movesense device found.
  final found = movesense.scanResults.first;
  await movesense.startScan();
  final device = await found;
  await movesense.stopScan();

  // 2. Connect, and wait until the device is ready.
  final connected = device.statusEvents
      .firstWhere((status) => status == MovesenseDeviceStatus.connected);
  await device.connect();
  await connected;

  // 3. Stream heart rate.
  device.hr.listen((hr) => print('Heart rate: ${hr.average} bpm'));
}
```

For brevity, the quick start leaves out error handling. In an app, also consider these cases:

* If no sensor is found, or the device never connects, it waits forever. On failure, `statusEvents` emits `MovesenseDeviceStatus.error`. Handle that, and add a timeout.
* On iOS, `scanResults` emits an `MdsError` if Bluetooth is not powered on yet. Scanning then starts by itself once it is.

## Usage

Import `package:movesense_plus/movesense_plus.dart`. There are two entry points:

* `Movesense` handles scanning and raw MDS access.
* `MovesenseDevice` is the typed API for one sensor.

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

The same device is reported again for every advertisement it sends, so deduplicate by `address`.

### Connecting to a device

A `MovesenseDevice` comes from the scan, or you can create one directly when you know the address:

```dart
final device = MovesenseDevice(address: '0C:8C:DC:1B:23:BF');

device.statusEvents.listen((status) {
  print('Connection status: ${status.name}');
});

await device.connect();
```

> [!NOTE]
> The `address` format is platform dependent:
>
> * On Android, it is the Bluetooth MAC address, e.g. `0C:8C:DC:1B:23:BF`.
> * On iOS, it is the UUID of the peripheral, e.g. `89BD8BF8-C9E7-0395-3B1D-119082516DDE`.

`connect()` completes as soon as the platform accepts the connect command, not when the device is connected. When the device connects, the plugin first fetches the device info and battery level. It then sets `status` to `MovesenseDeviceStatus.connected`, so `isConnected` becomes true, and emits the new status on `statusEvents`.

Call `disconnect()` to end the connection. When you no longer need the device object, call `dispose()`. To follow connection events for all devices at once, listen to `movesense.connectionEvents`.

### Device information, battery status and system states

Once connected, these are available:

| API | Returns |
|---|---|
| `deviceInfo` / `getDeviceInfo()` | The full [device info](https://www.movesense.com/docs/esw/api_reference/#info) as a `MovesenseDeviceInfo` |
| `deviceType` | The hardware variant (`md`, `hrPlus`, `hr2`), derived from the device info |
| `batteryLevel` / `getBatteryStatus()` | The [battery level](https://www.movesense.com/docs/esw/api_reference/#systemstates), which Movesense reports as `ok` or `low` |
| `getState(MovesenseSystemState)` | The current [system state](https://www.movesense.com/docs/esw/api_reference/#systemstates) of a component (movement, connectors, tap, double tap, free fall) |

```dart
print('Product: ${device.deviceInfo?.productName}, serial: ${device.serial}');
print('Type: ${device.deviceType.name}, battery: ${device.batteryLevel.name}');

final connectors = await device.getState(MovesenseSystemState.connectors);
print('Strap: ${connectors?.state.name}');
```

### Streaming sensor data

A connected device has the following streams:

| Stream | Data | MDS resource | Rate |
|---|---|---|---|
| `hr` | `MovesenseHR`: average heart rate (bpm) and R-R intervals (ms) | `/Meas/HR` | 1 Hz |
| `ecg` | `MovesenseECG`: raw ECG samples | `/Meas/ECG/125` | 125 Hz |
| `imu` | `MovesenseIMU`: synchronized accelerometer (m/s²), gyroscope (deg/s) and magnetometer (µT) samples | `/Meas/IMU9/13` | 13 Hz |
| `temperature` | `MovesenseTemperature`: Kelvin, with a `celsius` getter. Movesense MD only. | `/Meas/Temp` | |

```dart
final subscription = device.hr.listen((hr) {
  print('Heart rate: ${hr.average}, R-R: ${hr.rr} ms');
});

// Stop streaming.
await subscription.cancel();
```

How the streams behave:

* Each stream is single-subscription. Every read of `hr`, `ecg` and so on returns a new stream. That stream opens its own MDS subscription when you listen, and closes it when you cancel.
* The connection is checked when you read the stream, not when you listen to it. A stream read before the device is connected emits a `StateError`.
* For other sample rates, use [raw MDS access](#raw-mds-access) together with `MovesenseECG.fromMovesenseData` or `MovesenseIMU.fromMovesenseData`.

### Streaming state change events

```dart
device.getStateEvents(MovesenseSystemState.tap).listen((state) {
  print('State: ${state.state.name} at ${state.timestamp}');
});
```

> [!NOTE]
> The Movesense firmware only allows [one state subscription at a time](https://github.com/petri-lipponen-movesense/mdsflutter/issues/15), and not every component is supported on every device. Only the `connectors` and `tap` states have been confirmed on the Movesense MD and HR2.

### Raw MDS access

You can reach any other [Movesense resource](https://www.movesense.com/docs/esw/api_reference/) with REST-style requests and subscriptions. On a connected device, the serial is filled in for you:

```dart
// Turn the LED on.
await device.request(MdsRequestMethod.put, '/Component/Led', contract: '{"isOn": true}');

// Accelerometer at 52 Hz, as raw JSON notification bodies.
device.subscribe('/Meas/Acc/52').listen(print);

// ECG at 256 Hz, parsed with the typed model (jsonDecode is from dart:convert).
device
    .subscribe('/Meas/ECG/256')
    .map((body) => MovesenseECG.fromMovesenseData(jsonDecode(body)))
    .listen(print);
```

Without a `MovesenseDevice`, use the `Movesense` client with full URIs:

```dart
final response = await movesense.request(MdsRequestMethod.get, Mds.createRequestUri(serial, '/Info'));
print(response.body);

movesense.subscribe(Mds.createSubscriptionUri(serial, '/Meas/HR')).listen(print);
```

How errors are reported:

* A failed request fails with an `MdsError` that carries the MDS status code. The code is `0` for local failures.
* A failed subscription emits an `MdsError` on its stream.
* `device.request()` throws a `StateError` when the device is not connected.

### mdsflutter compatibility

The static `Mds` and `MdsAsync` classes mirror the `mdsflutter` API (`Mds.connect`, `Mds.get`, `Mds.subscribe`, `MdsAsync.subscribe` and so on). Existing code can switch to this plugin by changing the import.

## Upgrading to 2.0.0

Version 2.0.0 is the Pigeon-based plugin that was previously published as `carp_movesense_flutter`. It replaces the `mdsflutter`-based 1.x releases of `movesense_plus`.

### From `movesense_plus` 1.x

Remove the manual Movesense SDK setup from your app:

* **iOS:** the `pod 'Movesense', :git => ...` line in your `Podfile`. If you added `use_modular_headers!` or `use_frameworks! :linkage => :static` only for Movesense, remove those too.
* **Android:** the vendored `android/libs/mdslib-*.aar` and its `flatDir` repository.

The API is new. The most common changes:

| 1.x | 2.0.0 |
|---|---|
| `Movesense().scan()`, `Movesense().devices` | `Movesense().startScan()`, `Movesense().scanResults` |
| `MovesenseDevice({address, serial, name, deviceType})`, all optional | `MovesenseDevice({required address, name})`; `serial`, `status` and `deviceType` are read-only |
| `connect()` and `disconnect()` return `void` | They return `Future<void>`; follow `statusEvents` for the outcome |
| `canConnect()` | Removed |
| `hr`, `ecg`, `imu`, ... are broadcast streams, empty when not connected | Single-subscription streams that emit a `StateError` when not connected |
| `DeviceConnectionStatus` | `MovesenseDeviceStatus` |
| `DeviceBatteryLevel` | `MovesenseBatteryLevel` |
| `SystemStateComponent` | `MovesenseSystemState` |
| `MovesenseDeviceType.MD`, `HR_PLUS`, `HR2`, `FLASH` | `MovesenseDeviceType.md`, `hrPlus`, `hr2`, `flash` |
| `MovesenseHR.average` as `int` | `double`, plus the full `rrData` list |
| `MovesenseTemperature.measurement` as `int` | `double`, plus a `celsius` getter |
| `MovesenseState` extends `MovesenseData`, with an `int` `timestamp` | A standalone class with an `int?` `timestamp` (null for `getState()` reads), plus `component` and `value` |
| `MovesenseDeviceInfo.fromMovesenseData(String)`, `fromMap`, `toMap`, `toJsonString` (and `fromMap`/`toMap` on `MovesenseAddressInfo`) | `fromMovesenseData(Map)`, `fromJson`, `toJson` |
| Positional data model constructors | Named constructors. The IMU sample classes keep positional `(x, y, z)` constructors, with `double` instead of `num` values. |

2.0.0 also fixes the IMU gyroscope and magnetometer samples, which 1.x read from the accelerometer array, so IMU data differs from 1.x.

### From `carp_movesense_flutter` 0.1.x

Rename `CarpMovesenseFlutter` to `Movesense`, and change the imports to `package:movesense_plus/movesense_plus.dart`.

In 0.1.x, `MovesenseDevice` was the plain scan result class. That class is now `MovesenseScanResult`. `scanResults` now emits the typed `MovesenseDevice`, which still has `name` and `address` but no `const` constructor.

If you have a custom platform implementation:

* Import `package:movesense_plus/movesense_plus_platform_interface.dart`.
* `CarpMovesenseFlutterPlatform` is now `MovesensePlatform`, and `PigeonCarpMovesenseFlutter` is now `PigeonMovesense`.
* `MethodChannelCarpMovesenseFlutter` has been removed.
* The platform's `scanResults` now emits `MovesenseScanResult`.

## Example app

The [`example/`](example) folder contains a tester app for the `Movesense` client, with screens for scanning, connecting, sending MDS requests, subscribing to resources and viewing the log. To run it, call `flutter run` from `example/` with a physical Android or iOS device connected.

| Scan | Device | Requests | Subscriptions | Logs |
|:---:|:---:|:---:|:---:|:---:|
| <img src="images/01_scan.PNG" width="160" alt="Scan screen"/> | <img src="images/02_device.PNG" width="160" alt="Device screen"/> | <img src="images/03_request.PNG" width="160" alt="Requests screen"/> | <img src="images/04_subscriptions.PNG" width="160" alt="Subscriptions screen"/> | <img src="images/05_logs.PNG" width="160" alt="Logs screen"/> |

## Contributing

Please file feature requests and bug reports as [issues](https://github.com/carp-dk/movesense_plus/issues). Pull requests are welcome.

### Project layout

| Path | Contents |
|---|---|
| `lib/movesense_plus.dart` | The public library, which exports the `lib/src/` files below (not `internal/`) |
| `lib/src/movesense_client.dart` | `Movesense`, the public client over the platform interface |
| `lib/src/movesense_device.dart` | `MovesenseDevice`, the typed device API |
| `lib/src/movesense_data.dart` | The typed data models (`MovesenseHR`, `MovesenseECG`, `MovesenseIMU`, ...) |
| `lib/src/movesense_models.dart` | `MdsRequestMethod`, `MovesenseScanResult`, connection events, `MdsResponse` and `MdsError` |
| `lib/src/mds_compat.dart` | The `mdsflutter`-compatible `Mds` and `MdsAsync` facades |
| `lib/src/internal/` | The Pigeon event router and JSON helpers |
| `lib/movesense_plus_platform_interface.dart`, `lib/movesense_plus_pigeon.dart` | The platform interface and its Pigeon-backed implementation. Pigeon DTOs never leak into the public API. |

### Pigeon

The Dart/native transport is generated with [Pigeon](https://pub.dev/packages/pigeon). The contracts live in `pigeons/` and are split by responsibility: `movesense_scan_*`, `movesense_connection_*`, `movesense_request_*` and `movesense_subscription_*`. After editing a contract, regenerate the bindings:

```sh
tool/generate_pigeon.sh
```

The generated code is written to these `gen/` folders:

* `lib/src/gen/pigeon/`
* `android/src/main/kotlin/dk/carp/movesense_plus/gen/`
* `ios/movesense_plus/Sources/movesense_plus/gen/`
* `macos/movesense_plus/Sources/movesense_plus/gen/`

The original `mdsflutter` callback message schema is kept in `protos/movesense_mds.proto` for reference. At runtime the plugin uses Pigeon DTOs instead of protobuf byte arrays.

### Movesense SDKs

The compiled SDKs come from the [movesense-mobile-lib](https://bitbucket.org/movesense/movesense-mobile-lib/src/master/) repository and are vendored in this repository:

* **Android** uses the Movesense `mdslib` AAR under `android/vendor`.
* **iOS** uses `MovesenseMDS.xcframework` under `ios/movesense_plus/Vendor`. You can rebuild it from the Movesense SDK with `tool/generate_movesense_mds_xcframework.sh`. Pass `--sign <identity>` to code-sign the framework (optional), or run the script with `--help` to see all options.
* **macOS** registers the same Pigeon channels but returns "unsupported" errors, because there is no macOS Movesense MDS binary to bundle.

## Credits

The native MDS bridging is based on [mdsflutter](https://github.com/tugberka/mdsflutter) and the improved fork at [petri-lipponen-movesense/mdsflutter](https://github.com/petri-lipponen-movesense/mdsflutter).

## License

This software is copyright (c) the [Copenhagen Research Platform](https://carp.dk/) at the [Technical University of Denmark](https://dtu.dk/) and is available 'as-is' under a [MIT license](LICENSE).
