// Contains connection-history data for the Movesense tester example.
//
// Parts:
// - `ConnectedDeviceHistoryEntry`, one past MDS connection record.

/// One device that has reached an MDS connection during this app session.
class ConnectedDeviceHistoryEntry {
  /// Creates a connection-history record.
  ConnectedDeviceHistoryEntry({
    required this.address,
    required this.serial,
    this.name,
    DateTime? lastConnectedAt,
  }) : lastConnectedAt = lastConnectedAt ?? DateTime.now();

  /// Android MAC address or Apple UUID used for reconnecting.
  final String address;

  /// MDS serial reported by the device.
  String serial;

  /// Most recent BLE advertisement name, when known.
  String? name;

  /// Last time the device reached an MDS connection in this app session.
  DateTime lastConnectedAt;

  /// Primary display name for history rows.
  String get displayName {
    final trimmedName = name?.trim();
    return trimmedName == null || trimmedName.isEmpty
        ? 'Movesense $serial'
        : trimmedName;
  }

  /// Compact timestamp for history rows.
  String get formattedTime {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(lastConnectedAt.hour)}:'
        '${twoDigits(lastConnectedAt.minute)}';
  }
}
