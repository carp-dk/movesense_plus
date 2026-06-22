import 'package:carp_movesense_flutter/carp_movesense_flutter.dart';
import 'package:carp_movesense_flutter/carp_movesense_flutter_pigeon.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCarpMovesenseHostGateway implements CarpMovesenseHostGateway {
  @override
  Future<void> setScanEnabled(bool enabled) async {}

  @override
  Future<void> setConnection(String address, bool connect) async {}

  @override
  Future<void> sendRequest(int requestId, MdsRequestMethod method, String uri, String contract) async {}

  @override
  Future<void> subscribe(int requestId, int subscriptionId, String uri, String contract) async {}

  @override
  Future<void> unsubscribe(int subscriptionId) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // test('generated Pigeon host API uses the expected channel contract', () async {
  //   final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  //   final channel = BasicMessageChannel<Object?>(
  //     'dev.flutter.pigeon.carp_movesense_flutter.CarpMovesenseHostApi.getPlatformVersion',
  //     CarpMovesenseHostApi.pigeonChannelCodec,
  //     binaryMessenger: messenger,
  //   );
  //   messenger.setMockDecodedMessageHandler<Object?>(channel, (_) async => <Object?>['42']);

  //   addTearDown(() {
  //     messenger.setMockDecodedMessageHandler<Object?>(channel, null);
  //   });

  //   final api = CarpMovesenseHostApi(binaryMessenger: messenger);

  //   expect(await api.getPlatformVersion(), '42');
  // });
}
