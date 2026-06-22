// Contains connection-history behavior for the example controller.
//
// Parts:
// - Connected-device history lookup.
// - Retry connection from a history entry.

part of 'movesense_example_controller.dart';

/// Connection-history operations for [MovesenseExampleController].
extension MovesenseExampleControllerHistory on MovesenseExampleController {
  /// Past MDS-connected devices, newest first.
  List<ConnectedDeviceHistoryEntry> get connectionHistory {
    final history = _connectionHistory.values.toList()
      ..sort((a, b) => b.lastConnectedAt.compareTo(a.lastConnectedAt));
    return List<ConnectedDeviceHistoryEntry>.unmodifiable(history);
  }

  /// Retries connection to a device from [entry].
  Future<void> retryConnection(ConnectedDeviceHistoryEntry entry) async {
    final device = _devices.putIfAbsent(
      entry.address,
      () => ExampleMovesenseDevice(address: entry.address, name: entry.name),
    );
    device.name ??= entry.name;
    device.serial ??= entry.serial;
    _selectedAddress = entry.address;
    _log('Retrying connection to ${entry.displayName} (${entry.address}).');
    await connect(device);
  }

  /// Adds or updates a history row after an MDS connection event.
  void _recordConnectedDevice(ExampleMovesenseDevice device) {
    final serial = device.serial;
    if (serial == null || serial.isEmpty) return;

    final existing = _connectionHistory[device.address];
    if (existing == null) {
      _connectionHistory[device.address] = ConnectedDeviceHistoryEntry(
        address: device.address,
        serial: serial,
        name: device.name,
      );
      return;
    }

    existing
      ..serial = serial
      ..name = device.name ?? existing.name
      ..lastConnectedAt = DateTime.now();
  }
}
