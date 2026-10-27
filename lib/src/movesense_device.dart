import 'dart:async';

import 'internal/json.dart';
import 'mds_compat.dart';
import 'movesense_client.dart';
import 'movesense_data.dart';
import 'movesense_models.dart';

/// Connection status of a [MovesenseDevice].
enum MovesenseDeviceStatus { disconnected, connecting, connected, error }

/// A Movesense sensor identified by its BLE [address].
///
/// Devices are emitted by [Movesense.scanResults], or created directly when the
/// address is known. The [address] format is platform dependent: the Bluetooth
/// MAC address on Android (e.g. `0C:8C:DC:1B:23:BF`) and the peripheral UUID on
/// iOS (e.g. `89BD8BF8-C9E7-0395-3B1D-119082516DDE`).
///
/// Call [connect] and follow [status] or [statusEvents]. Once connected, the
/// device info and battery level are fetched automatically and the typed sensor
/// streams ([hr], [ecg], [imu], [temperature], [getStateEvents]) become
/// available. Any other MDS resource can be reached with [request] and [subscribe].
class MovesenseDevice {
  /// Creates a device for [address], using [movesense] or a default [Movesense] client.
  MovesenseDevice({required this.address, this.name, Movesense? movesense}) : _movesense = movesense ?? Movesense();

  final Movesense _movesense;
  final _statusController = StreamController<MovesenseDeviceStatus>.broadcast();
  StreamSubscription<MovesenseConnectionEvent>? _connectionSubscription;
  MovesenseDeviceStatus _status = MovesenseDeviceStatus.disconnected;
  String? _serial;
  MovesenseDeviceInfo? _deviceInfo;
  MovesenseBatteryLevel _batteryLevel = MovesenseBatteryLevel.unknown;

  /// Bluetooth MAC address on Android and UUID string on iOS.
  final String address;

  /// BLE advertisement name, when known (e.g. `Movesense 233830000816`).
  final String? name;

  /// The current connection status.
  MovesenseDeviceStatus get status => _status;

  /// Emits every change of [status].
  Stream<MovesenseDeviceStatus> get statusEvents => _statusController.stream;

  /// Whether the MDS connection to the device is complete.
  bool get isConnected => _status == MovesenseDeviceStatus.connected;

  /// The device serial number. Available while connected.
  String? get serial => _serial;

  /// Device info fetched on connection, or by [getDeviceInfo].
  MovesenseDeviceInfo? get deviceInfo => _deviceInfo;

  /// Battery level fetched on connection, or by [getBatteryStatus].
  MovesenseBatteryLevel get batteryLevel => _batteryLevel;

  /// The hardware variant, derived from [deviceInfo].
  MovesenseDeviceType get deviceType => _deviceInfo?.deviceType ?? MovesenseDeviceType.unknown;

  /// Starts connecting to the device.
  ///
  /// Completes when the connect command has been accepted by the platform;
  /// follow [statusEvents] for the outcome. Does nothing when already
  /// connecting or connected.
  Future<void> connect() async {
    if (_status == MovesenseDeviceStatus.connecting || isConnected) return;
    _setStatus(MovesenseDeviceStatus.connecting);
    _connectionSubscription ??= _movesense.connectionEvents.where(_isOwnEvent).listen(_handleConnectionEvent);
    try {
      await _movesense.connect(address);
    } catch (_) {
      _setStatus(MovesenseDeviceStatus.error);
      rethrow;
    }
  }

  /// Disconnects from the device.
  Future<void> disconnect() async {
    if (_status == MovesenseDeviceStatus.disconnected) return;
    try {
      await _movesense.disconnect(address);
    } finally {
      _serial = null;
      _batteryLevel = MovesenseBatteryLevel.unknown;
      _setStatus(MovesenseDeviceStatus.disconnected);
    }
  }

  /// Fetches the `/Info` resource and caches it in [deviceInfo].
  ///
  /// Returns null when not connected. Fails with an [MdsError] on MDS errors.
  Future<MovesenseDeviceInfo?> getDeviceInfo() async {
    if (_serial == null) return null;
    final response = await request(MdsRequestMethod.get, '/Info');
    return _deviceInfo = MovesenseDeviceInfo.fromMovesenseData(decodeJsonObject(response.body));
  }

  /// Fetches the battery level from `/System/States/1` and caches it in [batteryLevel].
  ///
  /// Returns [MovesenseBatteryLevel.unknown] when not connected or when the
  /// device does not report its battery state.
  Future<MovesenseBatteryLevel> getBatteryStatus() async {
    if (_serial == null) return MovesenseBatteryLevel.unknown;
    try {
      final response = await request(MdsRequestMethod.get, _stateResource(MovesenseSystemState.battery));
      return _batteryLevel = MovesenseBatteryLevel.fromStateValue(decodeJsonObject(response.body)['Content']);
    } on MdsError {
      return _batteryLevel = MovesenseBatteryLevel.unknown;
    }
  }

  /// Reads the current state of a system state [component].
  ///
  /// Returns null when not connected or when the device does not support the component.
  Future<MovesenseState?> getState(MovesenseSystemState component) async {
    if (_serial == null) return null;
    try {
      final response = await request(MdsRequestMethod.get, _stateResource(component));
      return MovesenseState.fromMovesenseData(component, decodeJsonObject(response.body));
    } on MdsError {
      return null;
    }
  }

  /// Heart rate and R-R intervals from `/Meas/HR`, at 1 Hz.
  Stream<MovesenseHR> get hr => _subscribeTyped('/Meas/HR', MovesenseHR.fromMovesenseData);

  /// ECG samples from `/Meas/ECG/125`, at 125 Hz.
  ///
  /// Use [subscribe] with another `/Meas/ECG/{SampleRate}` resource and
  /// [MovesenseECG.fromMovesenseData] for other sample rates.
  Stream<MovesenseECG> get ecg => _subscribeTyped('/Meas/ECG/125', MovesenseECG.fromMovesenseData);

  /// 9-axis IMU samples from `/Meas/IMU9/13`, at 13 Hz.
  ///
  /// Use [subscribe] with another `/Meas/IMU9/{SampleRate}` resource and
  /// [MovesenseIMU.fromMovesenseData] for other sample rates.
  Stream<MovesenseIMU> get imu => _subscribeTyped('/Meas/IMU9/13', MovesenseIMU.fromMovesenseData);

  /// Temperature from `/Meas/Temp`. Only supported by the Movesense MD.
  Stream<MovesenseTemperature> get temperature => _subscribeTyped('/Meas/Temp', MovesenseTemperature.fromMovesenseData);

  /// State-change events of a system state [component].
  ///
  /// Movesense firmware only allows one state subscription at a time, and not
  /// all components are supported on all devices. Only `connectors` and `tap`
  /// have been confirmed on the MD and HR2.
  Stream<MovesenseState> getStateEvents(MovesenseSystemState component) {
    return _subscribeTyped(_stateResource(component), (data) => MovesenseState.fromMovesenseData(component, data));
  }

  /// Sends an MDS request to a [resource] on this device, e.g. `/Info`.
  ///
  /// Fails with a [StateError] when not connected and with an [MdsError] on MDS errors.
  Future<MdsResponse> request(MdsRequestMethod method, String resource, {String contract = '{}'}) async {
    final serial = _serial;
    if (serial == null) throw _notConnected();
    return _movesense.request(method, Mds.createRequestUri(serial, resource), contract: contract);
  }

  /// Subscribes to a [resource] on this device, e.g. `/Meas/Acc/52`, and emits
  /// raw JSON notification bodies.
  ///
  /// The stream emits a [StateError] when not connected. It is
  /// single-subscription; cancelling it unsubscribes from the resource.
  Stream<String> subscribe(String resource, {String contract = '{}'}) {
    final serial = _serial;
    if (serial == null) return Stream.error(_notConnected());
    return _movesense.subscribe(Mds.createSubscriptionUri(serial, resource), contract: contract);
  }

  /// Releases the status stream and stops following connection events.
  Future<void> dispose() async {
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    await _statusController.close();
  }

  Stream<T> _subscribeTyped<T>(String resource, T Function(Map<String, dynamic> data) parse) {
    return subscribe(resource).map((body) => parse(decodeJsonObject(body)));
  }

  bool _isOwnEvent(MovesenseConnectionEvent event) {
    final eventAddress = event.address;
    if (eventAddress != null && eventAddress.toUpperCase() == address.toUpperCase()) return true;
    return event.serial != null && event.serial == _serial;
  }

  Future<void> _handleConnectionEvent(MovesenseConnectionEvent event) async {
    switch (event.type) {
      case MovesenseConnectionEventType.bleConnected:
        break;
      case MovesenseConnectionEventType.connected:
        _serial = event.serial;
        try {
          await getDeviceInfo();
        } on Exception {
          // Device info is optional; the device is still usable without it.
        }
        await getBatteryStatus();
        _setStatus(MovesenseDeviceStatus.connected);
      case MovesenseConnectionEventType.disconnected:
        _serial = null;
        _batteryLevel = MovesenseBatteryLevel.unknown;
        _setStatus(MovesenseDeviceStatus.disconnected);
      case MovesenseConnectionEventType.error:
        _serial = null;
        _setStatus(MovesenseDeviceStatus.error);
    }
  }

  void _setStatus(MovesenseDeviceStatus status) {
    if (_status == status) return;
    _status = status;
    if (!_statusController.isClosed) _statusController.add(status);
  }

  String _stateResource(MovesenseSystemState component) => '/System/States/${component.stateId}';

  StateError _notConnected() => StateError('Movesense device $address is not connected.');

  @override
  String toString() => 'MovesenseDevice(address: $address, name: $name, status: ${_status.name})';
}
