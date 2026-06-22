// Contains the scanner list row for a discovered Movesense device.
//
// Parts:
// - `DeviceListTile`, a connect/disconnect row with route navigation.

import 'package:flutter/material.dart';

import '../app/movesense_routes.dart';
import '../models/example_device_status.dart';
import '../models/example_movesense_device.dart';
import '../state/movesense_example_scope.dart';

/// List tile that displays one discovered device and connection controls.
class DeviceListTile extends StatelessWidget {
  /// Creates a row for [device].
  const DeviceListTile({required this.device, super.key});

  /// Device rendered by this row.
  final ExampleMovesenseDevice device;

  @override
  Widget build(BuildContext context) {
    final controller = MovesenseExampleScope.watch(context);
    final connected = device.isConnected;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(device.status.icon),
        title: Text(device.displayName),
        subtitle: Text(
          <String>[
            device.address,
            if (device.serial != null) 'Serial ${device.serial}',
            device.status.label,
          ].join('\n'),
        ),
        isThreeLine: device.serial != null,
        selected: controller.selectedDevice?.address == device.address,
        onTap: () => controller.selectDevice(device.address),
        trailing: Wrap(
          spacing: 4,
          children: <Widget>[
            IconButton(
              tooltip: connected ? 'Disconnect' : 'Connect',
              onPressed: connected
                  ? () => controller.disconnect(device.address)
                  : () => controller.connect(device),
              icon: Icon(connected ? Icons.link_off : Icons.link),
            ),
            IconButton(
              tooltip: 'Open device route',
              onPressed: () {
                controller.selectDevice(device.address);
                Navigator.of(
                  context,
                ).pushNamed(MovesenseRoutes.device, arguments: device.address);
              },
              icon: const Icon(Icons.open_in_new),
            ),
          ],
        ),
      ),
    );
  }
}
