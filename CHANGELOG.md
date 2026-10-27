## 2.0.0

* **BREAKING**: `movesense_plus` is now the Pigeon-based plugin previously published as `carp_movesense_flutter`, replacing the `mdsflutter`-based 1.x releases
* Bundles the native Movesense MDS libraries for Android and iOS; remove the manual `pod 'Movesense'` and `mdslib` `.aar` setup from apps
* `Movesense` client with scanning, connection events, and raw MDS `request` / `subscribe` for any resource
* `MovesenseDevice` with connection `status`, `getDeviceInfo`, `getBatteryStatus`, `getState`, and typed `hr`, `ecg`, `imu`, `temperature` and `getStateEvents` streams
* Renamed `DeviceConnectionStatus`, `DeviceBatteryLevel` and `SystemStateComponent` to `MovesenseDeviceStatus`, `MovesenseBatteryLevel` and `MovesenseSystemState`; `MovesenseHR.average` is now a `double`
* Fix IMU gyroscope and magnetometer samples being read from the accelerometer array
* `Mds` / `MdsAsync` compatibility API for code migrating from `mdsflutter`

## 1.2.1

* update of example app to run on iOS incl. docs

## 1.2.0

* connect and disconnect method not async
* update to docs

## 1.1.1

Update of docs to highlight that the `address` format is platform dependent:

* on Android, the address is the Bluetooth MAC address (e.g. `0C:8C:DC:1B:23:BF`).
* on iOS, the address is the UUID of the device (e.g. `00000000-0000-0000-0000-000000000000`).

## 1.1.0

Added R-R interval to HR reading

## 1.0.0

Initial release supporting:

* scan for Movesense devices (and stop scanning again)
* connect and disconnect to a device
* get device and state information
* get a stream of the following data from a device:
  * heart rate
  * ECG
  * IMU
  * temperature
  * state events (movement, battery, connectors, double tap, tap, free fall)

---

The releases below were published as `carp_movesense_flutter`.

## 0.1.1

* Lower minimum SDK version to `3.12.0`

## 0.1.0

* Ported MDSFlutter
* Add Pigeon-based native communication
* Add scripts to setup movesense SDK for native platforms
* Add example app
* Add README.md screenshots
