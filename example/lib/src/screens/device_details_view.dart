// Contains selected-device details and quick Movesense operation tests.
//
// Parts:
// - `DeviceTab`, the tab wrapper.
// - `DeviceDetailsView`, selected-device details.
// - Private cards for summary and quick tests.

import 'package:flutter/material.dart';

import '../models/example_device_status.dart';
import '../models/example_movesense_device.dart';
import '../state/movesense_example_scope.dart';
import '../utils/movesense_example_helpers.dart';
import '../widgets/common_widgets.dart';

/// Device tab body used inside the home TabBarView.
class DeviceTab extends StatelessWidget {
  /// Creates the device tab.
  const DeviceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const DeviceDetailsView();
  }
}

/// Shows selected-device status and quick plugin functionality tests.
class DeviceDetailsView extends StatelessWidget {
  /// Creates a device details view, optionally locked to [address].
  const DeviceDetailsView({this.address, super.key});

  /// Platform-specific BLE address to display when opened from a route.
  final String? address;

  @override
  Widget build(BuildContext context) {
    final controller = MovesenseExampleScope.watch(context);
    final device = address == null
        ? controller.selectedDevice
        : firstOrNull(
            controller.devices.where(
              (candidate) => candidate.address == address,
            ),
          );

    if (controller.devices.isEmpty) {
      return const EmptyState(
        icon: Icons.sensors_off,
        title: 'No active device',
        message: 'Use the Scan tab to discover a Movesense device.',
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: DropdownButtonFormField<String>(
            key: ValueKey<String?>(device?.address),
            initialValue: device?.address,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Selected device',
              border: OutlineInputBorder(),
            ),
            items: controller.devices.map((device) {
              return DropdownMenuItem<String>(
                value: device.address,
                child: Text(
                  '${device.displayName} (${device.status.label})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) controller.selectDevice(value);
            },
          ),
        ),
        if (device == null)
          const EmptyState(
            icon: Icons.sensors_off,
            title: 'Device not found',
            message: 'Select one of the discovered devices.',
          )
        else ...<Widget>[
          _DeviceSummaryCard(device: device),
          _QuickDeviceTests(device: device),
        ],
      ],
    );
  }
}

class _DeviceSummaryCard extends StatelessWidget {
  const _DeviceSummaryCard({required this.device});

  final ExampleMovesenseDevice device;

  @override
  Widget build(BuildContext context) {
    final controller = MovesenseExampleScope.watch(context);
    final connected = device.isConnected;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(device.status.icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    device.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FilledButton.icon(
                  onPressed: connected
                      ? () => controller.disconnect(device.address)
                      : () => controller.connect(device),
                  icon: Icon(connected ? Icons.link_off : Icons.link),
                  label: Text(connected ? 'Disconnect' : 'Connect'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            KeyValueRow(label: 'Address', value: device.address),
            KeyValueRow(label: 'Serial', value: device.serial ?? 'Unknown'),
            KeyValueRow(label: 'Status', value: device.status.label),
            if (device.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: InlineError(message: device.error!),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickDeviceTests extends StatelessWidget {
  const _QuickDeviceTests({required this.device});

  final ExampleMovesenseDevice device;

  @override
  Widget build(BuildContext context) {
    final serial = device.serial ?? '';
    final enabled = serial.isNotEmpty && device.isConnected;
    final accKey = subscriptionKey('Accelerometer', serial);
    final hrKey = subscriptionKey('Heart rate', serial);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          ListTile(
            title: const Text('Quick tests'),
            subtitle: Text(
              enabled
                  ? 'Run common Movesense MDS operations.'
                  : 'Connect through MDS before running quick tests.',
            ),
          ),
          const Divider(height: 1),
          _TemperatureTile(enabled: enabled, serial: serial),
          _LedTile(enabled: enabled, serial: serial),
          _SubscriptionTile(
            enabled: enabled,
            keyName: accKey,
            resource: '/Meas/Acc/104',
            title: 'Accelerometer',
            icon: Icons.show_chart,
          ),
          _SubscriptionTile(
            enabled: enabled,
            keyName: hrKey,
            resource: '/Meas/HR',
            title: 'Heart rate',
            icon: Icons.monitor_heart,
          ),
        ],
      ),
    );
  }
}

class _TemperatureTile extends StatelessWidget {
  const _TemperatureTile({required this.enabled, required this.serial});

  final bool enabled;
  final String serial;

  @override
  Widget build(BuildContext context) {
    final controller = MovesenseExampleScope.watch(context);
    return ListTile(
      leading: const Icon(Icons.thermostat),
      title: const Text('Temperature'),
      subtitle: Text(controller.quickResult('temperature')),
      trailing: IconButton.filledTonal(
        tooltip: 'Read temperature',
        onPressed: enabled ? () => controller.readTemperature(serial) : null,
        icon: const Icon(Icons.download),
      ),
    );
  }
}

class _LedTile extends StatelessWidget {
  const _LedTile({required this.enabled, required this.serial});

  final bool enabled;
  final String serial;

  @override
  Widget build(BuildContext context) {
    final controller = MovesenseExampleScope.watch(context);
    return SwitchListTile(
      secondary: const Icon(Icons.lightbulb),
      title: const Text('LED'),
      subtitle: Text(controller.quickResult('led')),
      value: controller.ledOn,
      onChanged: enabled ? (value) => controller.setLed(serial, value) : null,
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  const _SubscriptionTile({
    required this.enabled,
    required this.keyName,
    required this.resource,
    required this.title,
    required this.icon,
  });

  final bool enabled;
  final String keyName;
  final String resource;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final controller = MovesenseExampleScope.watch(context);
    final serial = controller.selectedDevice?.serial ?? '';
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(
        formatSubscriptionPreview(controller.latestSubscriptionData(keyName)),
      ),
      value: controller.isSubscriptionActive(keyName),
      onChanged: enabled
          ? (value) {
              if (value) {
                controller.startSubscription(
                  keyName,
                  buildSubscriptionUri(serial: serial, resource: resource)!,
                  '{}',
                );
              } else {
                controller.stopSubscription(keyName);
              }
            }
          : null,
    );
  }
}
