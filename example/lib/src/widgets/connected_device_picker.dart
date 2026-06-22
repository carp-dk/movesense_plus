// Contains the connected-device serial picker used by tester forms.
//
// Parts:
// - `ConnectedDevicePicker`, a dropdown for connected device serials.

import 'package:flutter/material.dart';

import '../state/movesense_example_scope.dart';

/// Dropdown that seeds request/subscription forms from connected devices.
class ConnectedDevicePicker extends StatelessWidget {
  /// Creates a connected-device picker.
  const ConnectedDevicePicker({
    required this.selectedSerial,
    required this.onSelected,
    super.key,
  });

  /// Serial currently selected in the owning form.
  final String selectedSerial;

  /// Called when the user selects a connected serial.
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final connectedDevices = MovesenseExampleScope.watch(context)
        .connectedDevices
        .where((device) => device.serial != null && device.serial!.isNotEmpty)
        .toList();

    if (connectedDevices.isEmpty) return const SizedBox.shrink();

    final currentValue =
        connectedDevices.any((device) => device.serial == selectedSerial)
        ? selectedSerial
        : connectedDevices.first.serial;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: DropdownButtonFormField<String>(
        key: ValueKey<String?>(currentValue),
        initialValue: currentValue,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Connected device',
          border: OutlineInputBorder(),
        ),
        items: connectedDevices.map((device) {
          return DropdownMenuItem<String>(
            value: device.serial!,
            child: Text(
              '${device.displayName} (${device.serial})',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (serial) {
          if (serial != null) onSelected(serial);
        },
      ),
    );
  }
}
