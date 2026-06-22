// Contains the root Material app and dependency wiring for the example.
//
// Parts:
// - `MyApp`, the top-level MaterialApp.
// - `_MyAppState`, which owns the example controller lifecycle.

import 'package:flutter/material.dart';

import '../screens/home_page.dart';
import '../screens/route_pages.dart';
import '../state/movesense_example_scope.dart';
import 'movesense_routes.dart';

/// Root widget for the CARP Movesense tester example app.
class MyApp extends StatefulWidget {
  /// Creates the Movesense tester app root.
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final MovesenseExampleController _controller =
      MovesenseExampleController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CARP Movesense Tester',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: false),
        cardTheme: const CardThemeData(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
      ),
      builder: (context, child) {
        return MovesenseExampleScope(
          controller: _controller,
          child: child ?? const SizedBox.shrink(),
        );
      },
      routes: <String, WidgetBuilder>{
        MovesenseRoutes.home: (context) => const MovesenseHomePage(),
        MovesenseRoutes.device: (context) => const DeviceRoutePage(),
        MovesenseRoutes.requests: (context) => const RequestsRoutePage(),
        MovesenseRoutes.subscriptions: (context) {
          return const SubscriptionsRoutePage();
        },
        MovesenseRoutes.logs: (context) => const LogsRoutePage(),
      },
    );
  }
}
