import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:movesense_plus/movesense_plus.dart';
import 'package:movesense_plus/movesense_plus_pigeon.dart';
import 'package:movesense_plus/movesense_plus_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

const infoJson =
    '{"Content":{"manufacturerName":"Movesense Ltd","brandName":null,"productName":"Movesense",'
    '"variant":"Avocado","design":"black","hwCompatibilityId":"C","serial":"233830000816",'
    '"pcbaSerial":"80413336500828200000100022666H4233","sw":"2.1.5","hw":"H4","additionalVersionInfo":null,'
    '"addressInfo":[{"name":"BLE","address":"0C-8C-DC-1B-23-BF"},{"name":"DFU-BLE","address":"E9-AC-4C-25-9A-65"}],'
    '"apiLevel":"1"}}';

/// Scripted platform: records commands and replays canned responses and notifications.
class FakeMovesensePlatform extends MovesensePlatform with MockPlatformInterfaceMixin {
  final scanController = StreamController<MovesenseScanResult>.broadcast();
  final connectionController = StreamController<MovesenseConnectionEvent>.broadcast();
  final connectCalls = <String>[];
  final disconnectCalls = <String>[];
  final requestUris = <String>[];
  final responses = <String, MdsResponse>{};
  final notifications = <String, List<String>>{};
  final unsubscribed = <int>[];
  int _nextSubscriptionId = 0;

  @override
  Stream<MovesenseScanResult> get scanResults => scanController.stream;

  @override
  Stream<MovesenseConnectionEvent> get connectionEvents => connectionController.stream;

  @override
  Future<void> startScan() async {}

  @override
  Future<void> stopScan() async {}

  @override
  Future<void> connect(String address) async => connectCalls.add(address);

  @override
  Future<void> disconnect(String address) async => disconnectCalls.add(address);

  @override
  Future<MdsResponse> request(MdsRequestMethod method, String uri, String contract) async {
    requestUris.add(uri);
    final response = responses[uri];
    if (response == null) throw MdsError(404, 'No response scripted for $uri');
    return response;
  }

  @override
  int subscribe(
    String uri,
    String contract, {
    MdsSuccessCallback? onSubscribe,
    MdsErrorCallback? onSubscribeError,
    required MdsNotificationCallback onNotification,
    MdsErrorCallback? onSubscriptionError,
  }) {
    final id = ++_nextSubscriptionId;
    scheduleMicrotask(() {
      onSubscribe?.call(const MdsResponse(body: '', statusCode: 200));
      for (final body in notifications[uri] ?? const <String>[]) {
        onNotification(body);
      }
    });
    return id;
  }

  @override
  Future<void> unsubscribe(int subscriptionId) async => unsubscribed.add(subscriptionId);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('$PigeonMovesense is the default platform instance', () {
    expect(MovesensePlatform.instance, isInstanceOf<PigeonMovesense>());
  });

  group('Movesense', () {
    late FakeMovesensePlatform platform;
    late Movesense movesense;

    setUp(() {
      platform = FakeMovesensePlatform();
      movesense = Movesense(platform: platform);
    });

    test('scanResults wraps scan results in devices bound to the client', () async {
      final devices = movesense.scanResults.take(1).toList();
      platform.scanController.add(const MovesenseScanResult(name: 'Movesense 123', address: 'AA:BB'));

      final device = (await devices).single;
      expect(device.name, 'Movesense 123');
      expect(device.address, 'AA:BB');
      expect(device.status, MovesenseDeviceStatus.disconnected);
    });

    test('subscribe emits notification bodies and unsubscribes on cancel', () async {
      platform.notifications['123/Meas/Acc/13'] = ['{"Body":{"Timestamp":1}}'];

      final bodies = await movesense.subscribe('123/Meas/Acc/13').take(1).toList();

      expect(bodies, ['{"Body":{"Timestamp":1}}']);
      expect(platform.unsubscribed, [1]);
    });
  });

  group('MovesenseDevice', () {
    late FakeMovesensePlatform platform;
    late MovesenseDevice device;

    setUp(() {
      platform = FakeMovesensePlatform()
        ..responses['suunto://233830000816/Info'] = const MdsResponse(body: infoJson, statusCode: 200)
        ..responses['suunto://233830000816/System/States/1'] = const MdsResponse(body: '{"Content":0}', statusCode: 200);
      device = MovesenseDevice(
        address: 'AA:BB',
        name: 'Movesense 233830000816',
        movesense: Movesense(platform: platform),
      );
    });

    Future<void> connectDevice() async {
      await device.connect();
      platform.connectionController.add(
        const MovesenseConnectionEvent(type: MovesenseConnectionEventType.connected, address: 'aa:bb', serial: '233830000816'),
      );
      await pumpEventQueue();
    }

    test('connect reports connecting, then connected with device info and battery', () async {
      final statuses = <MovesenseDeviceStatus>[];
      device.statusEvents.listen(statuses.add);

      await device.connect();
      expect(device.status, MovesenseDeviceStatus.connecting);
      expect(platform.connectCalls, ['AA:BB']);

      platform.connectionController.add(
        const MovesenseConnectionEvent(type: MovesenseConnectionEventType.connected, address: 'aa:bb', serial: '233830000816'),
      );
      await pumpEventQueue();

      expect(device.isConnected, isTrue);
      expect(device.serial, '233830000816');
      expect(device.deviceInfo?.productName, 'Movesense');
      expect(device.deviceType, MovesenseDeviceType.hr2);
      expect(device.batteryLevel, MovesenseBatteryLevel.ok);
      expect(statuses, [MovesenseDeviceStatus.connecting, MovesenseDeviceStatus.connected]);
    });

    test('connects even when device info is unavailable', () async {
      platform.responses.remove('suunto://233830000816/Info');

      await connectDevice();

      expect(device.isConnected, isTrue);
      expect(device.deviceInfo, isNull);
      expect(device.deviceType, MovesenseDeviceType.unknown);
    });

    test('ignores connection events of other devices', () async {
      await device.connect();
      platform.connectionController.add(
        const MovesenseConnectionEvent(type: MovesenseConnectionEventType.connected, address: 'CC:DD', serial: '999'),
      );
      await pumpEventQueue();

      expect(device.status, MovesenseDeviceStatus.connecting);
      expect(device.serial, isNull);
    });

    test('handles a disconnect event that carries only the serial', () async {
      await connectDevice();

      platform.connectionController.add(
        const MovesenseConnectionEvent(type: MovesenseConnectionEventType.disconnected, serial: '233830000816'),
      );
      await pumpEventQueue();

      expect(device.status, MovesenseDeviceStatus.disconnected);
      expect(device.serial, isNull);
      expect(device.batteryLevel, MovesenseBatteryLevel.unknown);
    });

    test('disconnect sends the command and resets the status', () async {
      await connectDevice();

      await device.disconnect();

      expect(platform.disconnectCalls, ['AA:BB']);
      expect(device.status, MovesenseDeviceStatus.disconnected);
      expect(device.isConnected, isFalse);
    });

    test('hr stream maps notifications to typed readings', () async {
      await connectDevice();
      platform.notifications['233830000816/Meas/HR'] = ['{"Body":{"average":72.5,"rrData":[833]}}'];

      final reading = await device.hr.first;

      expect(reading.average, 72.5);
      expect(reading.rr, 833);
    });

    test('getStateEvents subscribes to the state resource of the component', () async {
      await connectDevice();
      platform.notifications['233830000816/System/States/4'] = ['{"Body":{"Timestamp":614897,"StateId":4,"NewState":1}}'];

      final state = await device.getStateEvents(MovesenseSystemState.tap).first;

      expect(state.state, MovesenseDeviceState.tap);
      expect(state.timestamp, 614897);
    });

    test('getState returns null when the component is unsupported', () async {
      await connectDevice();

      expect(await device.getState(MovesenseSystemState.freeFall), isNull);
    });

    test('streams and requests fail with StateError when not connected', () async {
      expect(device.hr, emitsError(isA<StateError>()));
      expect(device.request(MdsRequestMethod.get, '/Info'), throwsStateError);
      expect(await device.getDeviceInfo(), isNull);
      expect(await device.getBatteryStatus(), MovesenseBatteryLevel.unknown);
    });
  });
}
