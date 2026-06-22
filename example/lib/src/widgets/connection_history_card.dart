// Contains the connection-history card for the Movesense tester example.
//
// Parts:
// - `ConnectionHistoryCard`, history display with retry controls.

import 'package:flutter/material.dart';

import '../state/movesense_example_scope.dart';

/// Shows past connected devices and lets the user retry a connection.
class ConnectionHistoryCard extends StatelessWidget {
  /// Creates a connection-history card.
  const ConnectionHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MovesenseExampleScope.watch(context);
    final history = controller.connectionHistory;

    if (history.isEmpty) {
      return const Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(Icons.history),
          title: Text('Connection history'),
          subtitle: Text('Connected devices will appear here.'),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          const ListTile(
            leading: Icon(Icons.history),
            title: Text('Connection history'),
            subtitle: Text('Retry previous Movesense connections.'),
          ),
          const Divider(height: 1),
          for (final entry in history)
            ListTile(
              title: Text(
                entry.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${entry.serial}\n${entry.address}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              isThreeLine: true,
              trailing: IconButton.filledTonal(
                tooltip: 'Retry connection',
                onPressed: () => controller.retryConnection(entry),
                icon: const Icon(Icons.refresh),
              ),
            ),
        ],
      ),
    );
  }
}
