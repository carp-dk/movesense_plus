import 'package:flutter_test/flutter_test.dart';

import 'package:movesense_plus_example/main.dart';

void main() {
  testWidgets('builds routed tab tester shell', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('CARP Movesense Tester'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('Device'), findsOneWidget);
    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('Subscriptions'), findsOneWidget);
    expect(find.text('Logs'), findsOneWidget);
    expect(find.byTooltip('Logs'), findsOneWidget);
  });
}
