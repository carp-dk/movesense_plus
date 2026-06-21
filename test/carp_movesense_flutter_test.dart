import 'package:flutter_test/flutter_test.dart';
import 'package:carp_movesense_flutter/carp_movesense_flutter.dart';
import 'package:carp_movesense_flutter/carp_movesense_flutter_pigeon.dart';
import 'package:carp_movesense_flutter/carp_movesense_flutter_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCarpMovesenseFlutterPlatform
    with MockPlatformInterfaceMixin
    implements CarpMovesenseFlutterPlatform {
  @override
  Future<String> getPlatformVersion() => Future.value('42');
}

void main() {
  final CarpMovesenseFlutterPlatform initialPlatform =
      CarpMovesenseFlutterPlatform.instance;

  test('$PigeonCarpMovesenseFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<PigeonCarpMovesenseFlutter>());
  });

  test('getPlatformVersion', () async {
    CarpMovesenseFlutter carpMovesenseFlutterPlugin = CarpMovesenseFlutter();
    MockCarpMovesenseFlutterPlatform fakePlatform =
        MockCarpMovesenseFlutterPlatform();
    CarpMovesenseFlutterPlatform.instance = fakePlatform;

    expect(await carpMovesenseFlutterPlugin.getPlatformVersion(), '42');
  });
}
