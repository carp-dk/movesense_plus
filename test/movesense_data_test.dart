import 'package:flutter_test/flutter_test.dart';
import 'package:movesense_plus/movesense_plus.dart';

void main() {
  group('MovesenseDeviceInfo', () {
    const content = <String, dynamic>{
      'manufacturerName': 'Movesense Ltd',
      'brandName': null,
      'productName': 'Movesense',
      'variant': 'Avocado',
      'design': 'black',
      'hwCompatibilityId': 'C',
      'serial': '233830000816',
      'pcbaSerial': '80413336500828200000100022666H4233',
      'sw': '2.1.5',
      'hw': 'H4',
      'additionalVersionInfo': null,
      'addressInfo': [
        {'name': 'BLE', 'address': '0C-8C-DC-1B-23-BF'},
        {'name': 'DFU-BLE', 'address': 'E9-AC-4C-25-9A-65'},
      ],
      'apiLevel': '1',
    };

    test('parses the /Info response wrapper', () {
      final info = MovesenseDeviceInfo.fromMovesenseData({'Content': content});

      expect(info.productName, 'Movesense');
      expect(info.serial, '233830000816');
      expect(info.hw, 'H4');
      expect(info.deviceType, MovesenseDeviceType.hr2);
      expect(info.brandName, isNull);
      expect(info.addressInfo.map((a) => a.name), ['BLE', 'DFU-BLE']);
      expect(info.toJson(), content);
    });

    test('parses bare content as well', () {
      expect(MovesenseDeviceInfo.fromMovesenseData(content).sw, '2.1.5');
    });
  });

  test('MovesenseDeviceType is derived from the hardware type', () {
    expect(MovesenseDeviceType.fromHardwareType('a1'), MovesenseDeviceType.md);
    expect(MovesenseDeviceType.fromHardwareType('H3'), MovesenseDeviceType.hrPlus);
    expect(MovesenseDeviceType.fromHardwareType('H4'), MovesenseDeviceType.hr2);
    expect(MovesenseDeviceType.fromHardwareType(null), MovesenseDeviceType.unknown);
  });

  test('MovesenseBatteryLevel maps the raw state value', () {
    expect(MovesenseBatteryLevel.fromStateValue(0), MovesenseBatteryLevel.ok);
    expect(MovesenseBatteryLevel.fromStateValue(1), MovesenseBatteryLevel.low);
    expect(MovesenseBatteryLevel.fromStateValue(null), MovesenseBatteryLevel.unknown);
  });

  test('MovesenseHR parses average and R-R intervals', () {
    final hr = MovesenseHR.fromMovesenseData({
      'Body': {
        'average': 72.5,
        'rrData': [820, 833],
      },
      'Uri': '233830000816/Meas/HR',
      'Method': 'PUT',
    });

    expect(hr.average, 72.5);
    expect(hr.rrData, [820, 833]);
    expect(hr.rr, 833);
  });

  test('MovesenseECG parses timestamp and samples', () {
    final ecg = MovesenseECG.fromMovesenseData({
      'Body': {
        'Timestamp': 32591214,
        'Samples': [1, -2, 3],
      },
    });

    expect(ecg.timestamp, 32591214);
    expect(ecg.samples, [1, -2, 3]);
  });

  test('MovesenseTemperature converts Kelvin to Celsius', () {
    final temperature = MovesenseTemperature.fromMovesenseData({
      'Body': {'Timestamp': 100, 'Measurement': 298.15},
    });

    expect(temperature.measurement, 298.15);
    expect(temperature.celsius, closeTo(25.0, 0.001));
  });

  test('MovesenseIMU reads each sensor from its own array', () {
    final imu = MovesenseIMU.fromMovesenseData({
      'Body': {
        'Timestamp': 7,
        'ArrayAcc': [
          {'x': 1.0, 'y': 2.0, 'z': 9.8},
        ],
        'ArrayGyro': [
          {'x': 10, 'y': 20, 'z': 30},
        ],
        'ArrayMagn': [
          {'x': -1.5, 'y': 0.5, 'z': 40},
        ],
      },
    });

    expect(imu.timestamp, 7);
    expect(imu.accelerometer.single.z, 9.8);
    expect(imu.gyroscope.single.x, 10);
    expect(imu.magnetometer.single.z, 40);
  });

  group('MovesenseState', () {
    test('parses a GET response', () {
      final state = MovesenseState.fromMovesenseData(MovesenseSystemState.connectors, {'Content': 1});

      expect(state.state, MovesenseDeviceState.connected);
      expect(state.value, 1);
      expect(state.timestamp, isNull);
    });

    test('parses a state-change notification', () {
      final state = MovesenseState.fromMovesenseData(MovesenseSystemState.tap, {
        'Body': {'Timestamp': 614897, 'StateId': 4, 'NewState': 1},
      });

      expect(state.state, MovesenseDeviceState.tap);
      expect(state.timestamp, 614897);
    });

    test('decodes movement and free fall values', () {
      expect(MovesenseState.fromMovesenseData(MovesenseSystemState.movement, {'Content': 0}).state, MovesenseDeviceState.notMoving);
      expect(MovesenseState.fromMovesenseData(MovesenseSystemState.freeFall, {'Content': 1}).state, MovesenseDeviceState.freeFall);
    });
  });
}
