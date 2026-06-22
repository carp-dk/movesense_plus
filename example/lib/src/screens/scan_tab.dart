// Contains the BLE scan tab for the Movesense tester app.
//
// Parts:
// - `ScanTab`, scan controls and discovered-device list rendering.

import 'package:flutter/material.dart';

import '../state/movesense_example_scope.dart';
import '../widgets/connection_history_card.dart';
import '../widgets/common_widgets.dart';
import '../widgets/device_list_tile.dart';

/// Tab that starts/stops scanning and lists discovered Movesense devices.
class ScanTab extends StatelessWidget {
  /// Creates the scan tab.
  const ScanTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MovesenseExampleScope.watch(context);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              FilledButton.icon(
                onPressed: controller.isScanning ? controller.stopScan : controller.startScan,
                icon: Icon(controller.isScanning ? Icons.stop : Icons.play_arrow),
                label: Text(controller.isScanning ? 'Stop scan' : 'Start scan'),
              ),
              OutlinedButton.icon(
                onPressed: controller.devices.isEmpty ? null : controller.clearDevices,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear'),
              ),
              StatusPill(
                icon: controller.isScanning ? Icons.bluetooth_searching : Icons.bluetooth,
                label: controller.isScanning ? 'Scanning' : 'Idle',
              ),
            ],
          ),
        ),
        if (controller.lastError != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InlineError(message: controller.lastError!),
          ),
        const ConnectionHistoryCard(),
        Expanded(
          child: controller.devices.isEmpty
              ? const EmptyState(
                  icon: Icons.bluetooth_searching,
                  title: 'No devices discovered',
                  message: 'Start a scan to populate this list.',
                )
              : ListView.builder(
                  itemCount: controller.devices.length,
                  itemBuilder: (context, index) {
                    final device = controller.devices[index];
                    return DeviceListTile(device: device);
                  },
                ),
        ),
      ],
    );
  }
}
