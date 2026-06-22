import 'package:flutter_test/flutter_test.dart';
import 'package:carp_movesense_flutter/carp_movesense_flutter.dart';
import 'package:carp_movesense_flutter/carp_movesense_flutter_pigeon.dart';
import 'package:carp_movesense_flutter/carp_movesense_flutter_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCarpMovesenseFlutterPlatform with MockPlatformInterfaceMixin implements CarpMovesenseFlutterPlatform {
  @override
  Stream<MovesenseDevice> get scanResults => const Stream.empty();

  @override
  Stream<MovesenseConnectionEvent> get connectionEvents => const Stream.empty();

  @override
  Future<void> startScan() async {}

  @override
  Future<void> stopScan() async {}

  @override
  Future<void> connect(String address) async {}

  @override
  Future<void> disconnect(String address) async {}

  @override
  Future<MdsResponse> request(MdsRequestMethod method, String uri, String contract) async {
    return const MdsResponse(body: '{}', statusCode: 200);
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
    return 1;
  }

  @override
  Future<void> unsubscribe(int subscriptionId) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final CarpMovesenseFlutterPlatform initialPlatform = CarpMovesenseFlutterPlatform.instance;

  test('$PigeonCarpMovesenseFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<PigeonCarpMovesenseFlutter>());
  });
}
