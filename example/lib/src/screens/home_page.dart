// Contains the tabbed home screen for the Movesense tester app.

import 'package:flutter/material.dart';

import '../app/movesense_routes.dart';
import 'device_details_view.dart';
import 'log_view.dart';
import 'request_tester_view.dart';
import 'scan_tab.dart';
import 'subscription_tester_view.dart';

/// Main tabbed screen used when the app opens.
class MovesenseHomePage extends StatelessWidget {
  /// Creates the home page.
  const MovesenseHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CARP Movesense Tester'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.bug_report),
              tooltip: 'Logs',
              onPressed: () =>
                  Navigator.of(context).pushNamed(MovesenseRoutes.logs),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: <Widget>[
              Tab(icon: Icon(Icons.bluetooth_searching), text: 'Scan'),
              Tab(icon: Icon(Icons.sensors), text: 'Device'),
              Tab(icon: Icon(Icons.http), text: 'Requests'),
              Tab(icon: Icon(Icons.rss_feed), text: 'Subscriptions'),
              Tab(icon: Icon(Icons.bug_report), text: 'Logs'),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            ScanTab(),
            DeviceTab(),
            RequestTesterView(),
            SubscriptionTesterView(),
            LogView(),
          ],
        ),
      ),
    );
  }
}
