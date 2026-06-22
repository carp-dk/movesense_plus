// Contains runtime permission handling for the Movesense tester example.
//
// Parts:
// - `MovesensePermissionService`, Android Bluetooth runtime permission checks.
// - `MovesensePermissionResult`, a small permission outcome model.

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Result returned after checking or requesting Movesense permissions.
class MovesensePermissionResult {
  /// Creates a permission result.
  const MovesensePermissionResult({
    required this.granted,
    required this.message,
  });

  /// Whether all required runtime permissions are granted.
  final bool granted;

  /// Human-readable status or error message.
  final String message;
}

/// Requests Android runtime permissions needed for BLE scan and connection.
class MovesensePermissionService {
  /// Ensures Android Bluetooth scan/connect permissions are granted.
  ///
  /// Non-Android platforms return granted because iOS/macOS permission prompts
  /// are handled by the platform Bluetooth stack.
  Future<MovesensePermissionResult> ensureBluetoothPermissions() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const MovesensePermissionResult(
        granted: true,
        message: 'No Android Bluetooth runtime permission required.',
      );
    }

    final statuses = await <Permission>[
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    final denied = statuses.entries
        .where((entry) => !entry.value.isGranted)
        .map((entry) => entry.key)
        .toList();
    if (denied.isEmpty) {
      return const MovesensePermissionResult(
        granted: true,
        message: 'Bluetooth permissions granted.',
      );
    }

    final permanentlyDenied = denied.any(
      (permission) => statuses[permission]?.isPermanentlyDenied ?? false,
    );
    return MovesensePermissionResult(
      granted: false,
      message: permanentlyDenied
          ? 'Bluetooth permission permanently denied. Enable it in Android settings.'
          : 'Bluetooth scan/connect permission is required.',
    );
  }
}
