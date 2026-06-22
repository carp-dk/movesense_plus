// Contains display state for discovered Movesense devices.
//
// Parts:
// - `ExampleDeviceStatus`, the connection state enum.
// - `ExampleDeviceStatusLabel`, UI metadata for each state.

import 'package:flutter/material.dart';

/// Connection state tracked by the example app for one Movesense device.
enum ExampleDeviceStatus {
  /// The device is known but not connected.
  notConnected,

  /// A connect command has been sent.
  connecting,

  /// BLE is connected, but MDS is not fully connected yet.
  bleConnected,

  /// MDS is connected and request/subscription APIs can be used.
  connected,
}

/// UI labels and icons for [ExampleDeviceStatus].
extension ExampleDeviceStatusLabel on ExampleDeviceStatus {
  /// Human-readable status text.
  String get label {
    switch (this) {
      case ExampleDeviceStatus.notConnected:
        return 'Not connected';
      case ExampleDeviceStatus.connecting:
        return 'Connecting';
      case ExampleDeviceStatus.bleConnected:
        return 'BLE connected';
      case ExampleDeviceStatus.connected:
        return 'MDS connected';
    }
  }

  /// Material icon representing the status.
  IconData get icon {
    switch (this) {
      case ExampleDeviceStatus.notConnected:
        return Icons.bluetooth_disabled;
      case ExampleDeviceStatus.connecting:
        return Icons.sync;
      case ExampleDeviceStatus.bleConnected:
        return Icons.bluetooth_connected;
      case ExampleDeviceStatus.connected:
        return Icons.sensors;
    }
  }
}
