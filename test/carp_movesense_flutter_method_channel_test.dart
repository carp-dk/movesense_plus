import 'package:carp_movesense_flutter/carp_movesense_flutter_method_channel.dart';
import 'package:carp_movesense_flutter/carp_movesense_flutter_pigeon.dart';
import 'package:carp_movesense_flutter/src/pigeon/carp_movesense_api.g.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCarpMovesenseHostGateway implements CarpMovesenseHostGateway {
  @override
  Future<String> getPlatformVersion() async => '42';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Pigeon adapter delegates to the host gateway', () async {
    final platform = PigeonCarpMovesenseFlutter(
      gateway: FakeCarpMovesenseHostGateway(),
    );

    expect(await platform.getPlatformVersion(), '42');
  });

  test('generated Pigeon host API uses the expected channel contract', () async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final channel = BasicMessageChannel<Object?>(
      'dev.flutter.pigeon.carp_movesense_flutter.CarpMovesenseHostApi.getPlatformVersion',
      CarpMovesenseHostApi.pigeonChannelCodec,
      binaryMessenger: messenger,
    );
    messenger.setMockDecodedMessageHandler<Object?>(
      channel,
      (_) async => <Object?>['42'],
    );

    addTearDown(() {
      messenger.setMockDecodedMessageHandler<Object?>(channel, null);
    });

    final api = CarpMovesenseHostApi(binaryMessenger: messenger);

    expect(await api.getPlatformVersion(), '42');
  });

  test(
    'deprecated MethodChannel compatibility wrapper uses Pigeon transport',
    () async {
      final platform = MethodChannelCarpMovesenseFlutter(
        gateway: FakeCarpMovesenseHostGateway(),
      );

      expect(await platform.getPlatformVersion(), '42');
    },
  );
}
