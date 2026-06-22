// Contains scan and connection event handlers for the example controller.
//
// Parts:
// - BLE scan-result handling.
// - MDS connection lifecycle handling.

part of 'movesense_example_controller.dart';

/// Native event handlers for [MovesenseExampleController].
extension MovesenseExampleControllerEvents on MovesenseExampleController {
  /// Stores one discovered Movesense scan result.
  void _handleScanResult(MovesenseDevice device) {
    final knownDevice = _devices[device.address];
    if (knownDevice == null) {
      _devices[device.address] = ExampleMovesenseDevice(
        address: device.address,
        name: device.name,
      );
      _selectedAddress ??= device.address;
      _log('Found ${device.name ?? 'Movesense device'} at ${device.address}.');
      return;
    }

    knownDevice.name = device.name ?? knownDevice.name;
    _emitChange();
  }

  /// Applies one native connection lifecycle event to the selected device state.
  void _handleConnectionEvent(MovesenseConnectionEvent event) {
    final address = event.address;
    if (address == null || address.isEmpty) {
      _log('Connection event without address: ${event.type.name}.');
      return;
    }

    final device = _devices.putIfAbsent(
      address,
      () => ExampleMovesenseDevice(address: address),
    );
    _selectedAddress ??= address;

    switch (event.type) {
      case MovesenseConnectionEventType.bleConnected:
        device.status = ExampleDeviceStatus.bleConnected;
        device.error = null;
        _log('BLE connected: $address.');
      case MovesenseConnectionEventType.connected:
        device.status = ExampleDeviceStatus.connected;
        device.serial = event.serial ?? device.serial;
        device.error = null;
        _selectedAddress = address;
        _recordConnectedDevice(device);
        _log('MDS connected: $address serial ${device.serial ?? 'unknown'}.');
      case MovesenseConnectionEventType.disconnected:
        device.status = ExampleDeviceStatus.notConnected;
        _log('Disconnected: $address.');
      case MovesenseConnectionEventType.error:
        device.status = ExampleDeviceStatus.notConnected;
        device.error = event.error;
        _recordError(
          'Connection error for $address',
          event.error ?? 'Unknown connection error',
          StackTrace.current,
        );
    }
    _emitChange();
  }
}
