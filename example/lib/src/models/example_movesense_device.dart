// Contains the example app's view model for one Movesense peripheral.
//
// Parts:
// - `ExampleMovesenseDevice`, mutable UI state for a discovered device.

import 'example_device_status.dart';

/// Device state maintained by the example app while testing plugin behavior.
class ExampleMovesenseDevice {
  /// Creates a device with a platform-specific BLE [address].
  ExampleMovesenseDevice({required this.address, this.name});

  /// Android MAC address or Apple UUID reported by the plugin.
  final String address;

  /// Last advertised BLE name, when available.
  String? name;

  /// MDS serial reported after a full MDS connection.
  String? serial;

  /// Last connection error associated with this device.
  String? error;

  /// Current connection status shown in the UI.
  ExampleDeviceStatus status = ExampleDeviceStatus.notConnected;

  /// Name to display when advertisements do not include a useful name.
  String get displayName {
    final trimmedName = name?.trim();
    return trimmedName == null || trimmedName.isEmpty
        ? 'Movesense device'
        : trimmedName;
  }

  /// Whether the device has a live MDS connection.
  bool get isConnected => status == ExampleDeviceStatus.connected;
}
