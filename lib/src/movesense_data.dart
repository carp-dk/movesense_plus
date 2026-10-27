/// Base class for timestamped Movesense data samples.
abstract class MovesenseData {
  const MovesenseData(this.timestamp);

  /// Device-local timestamp of this sample in milliseconds since the sensor booted.
  ///
  /// See https://www.movesense.com/docs/esw/api_reference/#time
  final int timestamp;
}

/// Movesense hardware variants, derived from the `hw` field of [MovesenseDeviceInfo].
enum MovesenseDeviceType {
  /// Unknown or unrecognized hardware.
  unknown,

  /// Movesense Medical sensor (hardware type `A1`).
  md,

  /// Movesense Active HR+ sensor (hardware type `H3`).
  hrPlus,

  /// Movesense Active HR2 sensor (hardware type `H4`).
  hr2,

  /// Movesense FLASH sensor. Not detected automatically.
  flash;

  /// Derives the device type from the `hw` field of the `/Info` resource.
  static MovesenseDeviceType fromHardwareType(String? hw) {
    return switch (hw?.toUpperCase()) {
      'A1' => MovesenseDeviceType.md,
      'H3' => MovesenseDeviceType.hrPlus,
      'H4' => MovesenseDeviceType.hr2,
      _ => MovesenseDeviceType.unknown,
    };
  }
}

/// Battery level reported by the `/System/States/1` resource.
///
/// Movesense only reports whether the battery is OK or low.
enum MovesenseBatteryLevel {
  ok,
  low,
  unknown;

  /// Maps the raw state value (`0` = OK, `1` = low) to a battery level.
  static MovesenseBatteryLevel fromStateValue(Object? value) {
    return switch (value) {
      0 => MovesenseBatteryLevel.ok,
      1 => MovesenseBatteryLevel.low,
      _ => MovesenseBatteryLevel.unknown,
    };
  }
}

/// System state components available through `/System/States/{StateId}`.
///
/// The enum index is the Movesense `StateId`.
/// See https://www.movesense.com/docs/esw/api_reference/#systemstates
enum MovesenseSystemState {
  movement,
  battery,
  connectors,
  doubleTap,
  tap,
  freeFall;

  /// The Movesense `StateId` of this component.
  int get stateId => index;
}

/// The decoded state of a [MovesenseSystemState] component.
enum MovesenseDeviceState {
  /// Unknown state.
  unknown,

  /// Device is moving.
  moving,

  /// Device is not moving.
  notMoving,

  /// Device is connected to gear (e.g. a strap).
  connected,

  /// Device is disconnected from gear.
  disconnected,

  /// Device was tapped once.
  tap,

  /// Device was double tapped.
  doubleTap,

  /// Device is under acceleration.
  acceleration,

  /// Device is in free fall.
  freeFall,
}

/// Information about a Movesense device and the firmware running on it, as
/// returned by the `/Info` resource.
///
/// See https://www.movesense.com/docs/esw/api_reference/#info
class MovesenseDeviceInfo {
  const MovesenseDeviceInfo({
    this.manufacturerName = '',
    this.brandName,
    this.productName = '',
    this.variant = '',
    this.design = '',
    this.hwCompatibilityId = '',
    this.serial = '',
    this.pcbaSerial = '',
    this.sw = '',
    this.hw = '',
    this.additionalVersionInfo,
    this.addressInfo = const [],
    this.apiLevel = '',
  });

  /// Builds device info from a decoded `/Info` response.
  ///
  /// Accepts both the `{"Content": {...}}` response wrapper and the bare content.
  factory MovesenseDeviceInfo.fromMovesenseData(Map<String, dynamic> data) {
    final content = data['Content'];
    return MovesenseDeviceInfo.fromJson(content is Map ? Map<String, dynamic>.from(content) : data);
  }

  /// Builds device info from the bare `/Info` content object.
  factory MovesenseDeviceInfo.fromJson(Map<String, dynamic> json) {
    final addresses = json['addressInfo'];
    return MovesenseDeviceInfo(
      manufacturerName: _string(json['manufacturerName']),
      brandName: _nullableString(json['brandName']),
      productName: _string(json['productName']),
      variant: _string(json['variant']),
      design: _string(json['design']),
      hwCompatibilityId: _string(json['hwCompatibilityId']),
      serial: _string(json['serial']),
      pcbaSerial: _string(json['pcbaSerial']),
      sw: _string(json['sw']),
      hw: _string(json['hw']),
      additionalVersionInfo: _nullableString(json['additionalVersionInfo']),
      addressInfo: addresses is List
          ? addresses
                .whereType<Map>()
                .map((entry) => MovesenseAddressInfo.fromJson(Map<String, dynamic>.from(entry)))
                .toList(growable: false)
          : const [],
      apiLevel: _string(json['apiLevel']),
    );
  }

  final String manufacturerName;
  final String? brandName;
  final String productName;
  final String variant;
  final String design;
  final String hwCompatibilityId;

  /// The device serial number, used to address the device in MDS URIs.
  final String serial;
  final String pcbaSerial;

  /// Firmware (software) version.
  final String sw;

  /// Hardware type, e.g. `A1` for the Movesense MD. See [deviceType].
  final String hw;
  final String? additionalVersionInfo;
  final List<MovesenseAddressInfo> addressInfo;
  final String apiLevel;

  /// The hardware variant derived from [hw].
  MovesenseDeviceType get deviceType => MovesenseDeviceType.fromHardwareType(hw);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'manufacturerName': manufacturerName,
      'brandName': brandName,
      'productName': productName,
      'variant': variant,
      'design': design,
      'hwCompatibilityId': hwCompatibilityId,
      'serial': serial,
      'pcbaSerial': pcbaSerial,
      'sw': sw,
      'hw': hw,
      'additionalVersionInfo': additionalVersionInfo,
      'addressInfo': addressInfo.map((address) => address.toJson()).toList(growable: false),
      'apiLevel': apiLevel,
    };
  }

  @override
  String toString() {
    return 'MovesenseDeviceInfo(productName: $productName, serial: $serial, hw: $hw, sw: $sw)';
  }
}

/// One entry of the `addressInfo` list in [MovesenseDeviceInfo].
class MovesenseAddressInfo {
  const MovesenseAddressInfo({required this.name, required this.address});

  factory MovesenseAddressInfo.fromJson(Map<String, dynamic> json) {
    return MovesenseAddressInfo(name: _string(json['name']), address: _string(json['address']));
  }

  /// Address type, e.g. `BLE` or `DFU-BLE`.
  final String name;
  final String address;

  Map<String, dynamic> toJson() => <String, dynamic>{'name': name, 'address': address};

  @override
  String toString() => 'MovesenseAddressInfo(name: $name, address: $address)';
}

/// Heart rate reading from the `/Meas/HR` resource.
///
/// See https://www.movesense.com/docs/esw/api_reference/#meashr
class MovesenseHR {
  const MovesenseHR({required this.average, this.rrData = const []});

  /// Builds a reading from a decoded `/Meas/HR` notification.
  factory MovesenseHR.fromMovesenseData(Map<String, dynamic> data) {
    final body = _body(data);
    return MovesenseHR(average: _double(body['average']), rrData: _intList(body['rrData']));
  }

  /// Average heart rate in beats per minute.
  final double average;

  /// R-R intervals in milliseconds received since the previous notification.
  final List<int> rrData;

  /// The latest R-R interval in milliseconds, if any.
  int? get rr => rrData.isEmpty ? null : rrData.last;

  @override
  String toString() => 'MovesenseHR(average: $average, rr: $rr)';
}

/// A batch of single-channel ECG samples from the `/Meas/ECG/{SampleRate}` resource.
///
/// See https://www.movesense.com/docs/esw/api_reference/#measecg
class MovesenseECG extends MovesenseData {
  const MovesenseECG({required int timestamp, required this.samples}) : super(timestamp);

  /// Builds a batch from a decoded `/Meas/ECG` notification.
  factory MovesenseECG.fromMovesenseData(Map<String, dynamic> data) {
    final body = _body(data);
    return MovesenseECG(timestamp: _int(body['Timestamp']), samples: _intList(body['Samples']));
  }

  /// Raw (unscaled) ECG samples.
  final List<int> samples;

  @override
  String toString() => 'MovesenseECG(timestamp: $timestamp, samples: ${samples.length})';
}

/// Temperature reading from the `/Meas/Temp` resource.
///
/// Only the Movesense MD has a temperature sensor.
/// See https://www.movesense.com/docs/esw/api_reference/#meastemperature
class MovesenseTemperature extends MovesenseData {
  const MovesenseTemperature({required int timestamp, required this.measurement}) : super(timestamp);

  /// Builds a reading from a decoded `/Meas/Temp` notification or GET response.
  factory MovesenseTemperature.fromMovesenseData(Map<String, dynamic> data) {
    final body = _body(data);
    return MovesenseTemperature(timestamp: _int(body['Timestamp']), measurement: _double(body['Measurement']));
  }

  /// Temperature in Kelvin.
  final double measurement;

  /// Temperature in degrees Celsius.
  double get celsius => measurement - 273.15;

  @override
  String toString() => 'MovesenseTemperature(timestamp: $timestamp, kelvin: $measurement)';
}

/// A batch of synchronized accelerometer, gyroscope and magnetometer samples from
/// the `/Meas/IMU9/{SampleRate}` resource.
///
/// See https://www.movesense.com/docs/esw/api_reference/#measimu
class MovesenseIMU extends MovesenseData {
  const MovesenseIMU({required int timestamp, required this.accelerometer, required this.gyroscope, required this.magnetometer})
    : super(timestamp);

  /// Builds a batch from a decoded `/Meas/IMU9` notification.
  factory MovesenseIMU.fromMovesenseData(Map<String, dynamic> data) {
    final body = _body(data);
    return MovesenseIMU(
      timestamp: _int(body['Timestamp']),
      accelerometer: _vectors(body['ArrayAcc'], MovesenseAccelerometerSample.new),
      gyroscope: _vectors(body['ArrayGyro'], MovesenseGyroscopeSample.new),
      magnetometer: _vectors(body['ArrayMagn'], MovesenseMagnetometerSample.new),
    );
  }

  final List<MovesenseAccelerometerSample> accelerometer;
  final List<MovesenseGyroscopeSample> gyroscope;
  final List<MovesenseMagnetometerSample> magnetometer;

  @override
  String toString() => 'MovesenseIMU(timestamp: $timestamp, samples: ${accelerometer.length})';
}

/// One accelerometer sample in m/s², including gravity.
class MovesenseAccelerometerSample {
  const MovesenseAccelerometerSample(this.x, this.y, this.z);

  final double x, y, z;

  @override
  String toString() => 'Acc($x, $y, $z)';
}

/// One gyroscope sample in degrees per second.
class MovesenseGyroscopeSample {
  const MovesenseGyroscopeSample(this.x, this.y, this.z);

  final double x, y, z;

  @override
  String toString() => 'Gyro($x, $y, $z)';
}

/// One magnetometer sample in microtesla.
class MovesenseMagnetometerSample {
  const MovesenseMagnetometerSample(this.x, this.y, this.z);

  final double x, y, z;

  @override
  String toString() => 'Magn($x, $y, $z)';
}

/// The state of one [MovesenseSystemState] component, read with a GET or
/// received as a state-change notification.
///
/// See https://www.movesense.com/docs/esw/api_reference/#systemstates
class MovesenseState {
  const MovesenseState({required this.component, required this.state, required this.value, this.timestamp});

  /// Builds a state from a decoded `/System/States/{StateId}` GET response
  /// (`{"Content": value}`) or notification (`{"Body": {"Timestamp": ..., "NewState": ...}}`).
  factory MovesenseState.fromMovesenseData(MovesenseSystemState component, Map<String, dynamic> data) {
    final body = data['Body'];
    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      final value = _int(map['NewState']);
      return MovesenseState(component: component, state: _decodeState(component, value), value: value, timestamp: _int(map['Timestamp']));
    }
    final value = _int(data['Content']);
    return MovesenseState(component: component, state: _decodeState(component, value), value: value);
  }

  /// The system state component this value belongs to.
  final MovesenseSystemState component;

  /// The decoded state.
  final MovesenseDeviceState state;

  /// The raw state value reported by the device.
  final int value;

  /// Device-local timestamp in milliseconds for notifications; null for GET reads.
  final int? timestamp;

  static MovesenseDeviceState _decodeState(MovesenseSystemState component, int value) {
    return switch (component) {
      MovesenseSystemState.movement => value == 0 ? MovesenseDeviceState.notMoving : MovesenseDeviceState.moving,
      MovesenseSystemState.connectors => value == 0 ? MovesenseDeviceState.disconnected : MovesenseDeviceState.connected,
      MovesenseSystemState.doubleTap => value == 1 ? MovesenseDeviceState.doubleTap : MovesenseDeviceState.unknown,
      MovesenseSystemState.tap => value == 1 ? MovesenseDeviceState.tap : MovesenseDeviceState.unknown,
      MovesenseSystemState.freeFall => value == 0 ? MovesenseDeviceState.acceleration : MovesenseDeviceState.freeFall,
      MovesenseSystemState.battery => MovesenseDeviceState.unknown,
    };
  }

  @override
  String toString() => 'MovesenseState(${component.name}: ${state.name})';
}

Map<String, dynamic> _body(Map<String, dynamic> data) {
  final body = data['Body'];
  return body is Map ? Map<String, dynamic>.from(body) : data;
}

String _string(Object? value) => value?.toString() ?? '';

String? _nullableString(Object? value) => value?.toString();

double _double(Object? value) => value is num ? value.toDouble() : 0;

int _int(Object? value) => value is num ? value.toInt() : 0;

List<int> _intList(Object? value) {
  if (value is! List) return const [];
  return value.map(_int).toList(growable: false);
}

List<T> _vectors<T>(Object? value, T Function(double x, double y, double z) create) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((sample) => create(_double(sample['x']), _double(sample['y']), _double(sample['z'])))
      .toList(growable: false);
}
