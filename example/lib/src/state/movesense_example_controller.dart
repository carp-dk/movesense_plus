// Contains controller state and plugin orchestration for the example app.
//
// Parts:
// - `MovesenseExampleController`, the ChangeNotifier backing all routes.
// - Public scan, connection, and request methods.
// - Part files for events, history, subscriptions, quick tests, and logging.

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:movesense_plus/movesense_plus.dart';
import 'package:flutter/foundation.dart';

import '../models/connected_device_history_entry.dart';
import '../models/example_device_status.dart';
import '../models/example_movesense_device.dart';
import '../models/log_entry.dart';
import '../permissions/movesense_permission_service.dart';
import '../utils/movesense_example_helpers.dart';

part 'movesense_example_controller_events.dart';
part 'movesense_example_controller_history.dart';
part 'movesense_example_controller_logging.dart';
part 'movesense_example_controller_quick_tests.dart';
part 'movesense_example_controller_subscriptions.dart';

/// Coordinates plugin calls and exposes state for the tester UI.
class MovesenseExampleController extends ChangeNotifier {
  /// Creates a controller backed by [plugin] or the default plugin instance.
  MovesenseExampleController({Movesense? plugin})
    : _plugin = plugin ?? Movesense() {
    _connectionSubscription = _plugin.connectionEvents.listen(
      _handleConnectionEvent,
      onError: (Object error, StackTrace stackTrace) {
        _recordError('Connection stream error', error, stackTrace);
      },
    );
    _log('Movesense example controller initialized.');
  }

  final Movesense _plugin;
  final Map<String, ExampleMovesenseDevice> _devices = {};
  final List<LogEntry> _logs = <LogEntry>[];
  final Map<String, StreamSubscription<String>> _subscriptions =
      <String, StreamSubscription<String>>{};
  final Map<String, String> _subscriptionLatestData = <String, String>{};
  final Map<String, String> _quickResults = <String, String>{};
  final Map<String, ConnectedDeviceHistoryEntry> _connectionHistory =
      <String, ConnectedDeviceHistoryEntry>{};
  final MovesensePermissionService _permissionService =
      MovesensePermissionService();

  StreamSubscription<MovesenseDevice>? _scanSubscription;
  StreamSubscription<MovesenseConnectionEvent>? _connectionSubscription;

  bool _isScanning = false;
  String? _selectedAddress;
  MdsResponse? _lastResponse;
  String? _lastError;
  bool _ledOn = false;

  /// Whether BLE scanning is currently enabled.
  bool get isScanning => _isScanning;

  /// Last known LED state after a successful quick LED write.
  bool get ledOn => _ledOn;

  /// Last MDS response returned by the request tester or quick tests.
  MdsResponse? get lastResponse => _lastResponse;

  /// Last rendered error message from any plugin operation.
  String? get lastError => _lastError;

  /// Discovered devices sorted by display name and address.
  List<ExampleMovesenseDevice> get devices {
    final sorted = _devices.values.toList()
      ..sort((first, second) {
        final nameCompare = first.displayName.compareTo(second.displayName);
        return nameCompare == 0
            ? first.address.compareTo(second.address)
            : nameCompare;
      });
    return List<ExampleMovesenseDevice>.unmodifiable(sorted);
  }

  /// Devices with an active MDS connection.
  List<ExampleMovesenseDevice> get connectedDevices {
    return devices.where((device) => device.isConnected).toList();
  }

  /// Device currently selected in the scanner or device tab.
  ExampleMovesenseDevice? get selectedDevice {
    final selectedAddress = _selectedAddress;
    if (selectedAddress == null) return firstOrNull(devices);
    return _devices[selectedAddress] ?? firstOrNull(devices);
  }

  /// Best serial to seed into request and subscription forms.
  String get preferredSerial {
    final selectedSerial = selectedDevice?.serial;
    if (selectedSerial != null && selectedSerial.isNotEmpty) {
      return selectedSerial;
    }
    for (final device in connectedDevices) {
      final serial = device.serial;
      if (serial != null && serial.isNotEmpty) return serial;
    }
    return '';
  }

  /// In-memory debugger log entries, newest first.
  List<LogEntry> get logs => List<LogEntry>.unmodifiable(_logs);

  /// Returns the latest quick-test result for [key].
  String quickResult(String key) => _quickResults[key] ?? '';

  /// Selects a discovered device by platform BLE address.
  void selectDevice(String address) {
    if (_selectedAddress == address) return;
    _selectedAddress = address;
    _emitChange();
  }

  /// Starts BLE scanning and subscribes to scan-result events.
  Future<void> startScan() async {
    if (_isScanning) return;
    if (!await _ensureBluetoothPermissions('scan')) return;
    _scanSubscription ??= _plugin.scanResults.listen(
      _handleScanResult,
      onError: (Object error, StackTrace stackTrace) {
        _recordError('Scan stream error', error, stackTrace);
      },
    );

    _isScanning = true;
    _lastError = null;
    _log('Starting BLE scan.');
    try {
      await _plugin.startScan();
      _log('BLE scan started.');
    } catch (error, stackTrace) {
      _isScanning = false;
      _recordError('Failed to start BLE scan', error, stackTrace);
    }
  }

  /// Stops BLE scanning.
  Future<void> stopScan() async {
    if (!_isScanning) return;
    _log('Stopping BLE scan.');
    try {
      await _plugin.stopScan();
      _isScanning = false;
      _log('BLE scan stopped.');
    } catch (error, stackTrace) {
      _recordError('Failed to stop BLE scan', error, stackTrace);
    }
  }

  /// Clears the discovered-device list.
  void clearDevices() {
    _devices.clear();
    _selectedAddress = null;
    _log('Discovered device list cleared.');
  }

  /// Sends a connect command for [device].
  Future<void> connect(ExampleMovesenseDevice device) async {
    if (!await _ensureBluetoothPermissions('connect')) return;
    _selectedAddress = device.address;
    device.status = ExampleDeviceStatus.connecting;
    device.error = null;
    _log('Connecting to ${device.displayName} (${device.address}).');
    try {
      await _plugin.connect(device.address);
      _log('Connect command sent for ${device.address}.');
      _emitChange();
    } catch (error, stackTrace) {
      device.status = ExampleDeviceStatus.notConnected;
      _recordError('Failed to connect to ${device.address}', error, stackTrace);
    }
  }

  /// Stops subscriptions and disconnects the device at [address].
  Future<void> disconnect(String address) async {
    if (!await _ensureBluetoothPermissions('disconnect')) return;
    final device = _devices[address];
    await stopAllSubscriptions();
    _log('Disconnecting from ${device?.displayName ?? address}.');
    try {
      await _plugin.disconnect(address);
      device?.status = ExampleDeviceStatus.notConnected;
      _log('Disconnect command sent for $address.');
      _emitChange();
    } catch (error, stackTrace) {
      _recordError('Failed to disconnect from $address', error, stackTrace);
    }
  }

  /// Sends one MDS request and stores the response or rendered error.
  Future<MdsResponse?> sendRequest(
    MdsRequestMethod method,
    String uri,
    String contract,
  ) async {
    final normalizedContract = contract.trim().isEmpty ? '{}' : contract.trim();
    _log('Sending ${method.nativeName} request to $uri.');
    try {
      final response = await _plugin.request(
        method,
        uri,
        contract: normalizedContract,
      );
      _lastResponse = response;
      _lastError = null;
      _log(
        'Request completed with status ${response.statusCode}: '
        '${shorten(response.body)}',
      );
      _emitChange();
      return response;
    } catch (error, stackTrace) {
      _recordError('${method.nativeName} request failed', error, stackTrace);
      return null;
    }
  }

  /// Emits a change notification for part-file methods.
  void _emitChange() {
    notifyListeners();
  }

  Future<bool> _ensureBluetoothPermissions(String operation) async {
    final result = await _permissionService.ensureBluetoothPermissions();
    _log('${result.message} Operation: $operation.');
    if (result.granted) return true;

    _lastError = result.message;
    _emitChange();
    return false;
  }

  @override
  void dispose() {
    unawaited(_scanSubscription?.cancel());
    unawaited(_connectionSubscription?.cancel());
    for (final subscription in _subscriptions.values) {
      unawaited(subscription.cancel());
    }
    if (_isScanning) {
      unawaited(_plugin.stopScan());
    }
    super.dispose();
  }
}
