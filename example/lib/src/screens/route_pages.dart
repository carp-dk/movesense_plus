// Contains standalone named-route pages for the Movesense tester app.
//
// Parts:
// - `DeviceRoutePage`, `RequestsRoutePage`, `SubscriptionsRoutePage`.
// - `LogsRoutePage`.

import 'package:flutter/material.dart';

import 'device_details_view.dart';
import 'log_view.dart';
import 'request_tester_view.dart';
import 'subscription_tester_view.dart';

/// Standalone route for the selected device details and quick tests.
class DeviceRoutePage extends StatelessWidget {
  /// Creates the device route page.
  const DeviceRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    final address = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      appBar: AppBar(title: const Text('Device route')),
      body: DeviceDetailsView(address: address),
    );
  }
}

/// Standalone route for testing one-shot MDS requests.
class RequestsRoutePage extends StatelessWidget {
  /// Creates the request tester route page.
  const RequestsRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Requests route')),
      body: const RequestTesterView(),
    );
  }
}

/// Standalone route for testing MDS subscriptions.
class SubscriptionsRoutePage extends StatelessWidget {
  /// Creates the subscription tester route page.
  const SubscriptionsRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions route')),
      body: const SubscriptionTesterView(),
    );
  }
}

/// Standalone route for reviewing debugger logs.
class LogsRoutePage extends StatelessWidget {
  /// Creates the log route page.
  const LogsRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logs route')),
      body: const LogView(),
    );
  }
}
