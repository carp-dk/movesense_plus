// Contains the in-app debugger log screen.
//
// Parts:
// - `LogView`, a clearable list of controller log entries.

import 'package:flutter/material.dart';

import '../state/movesense_example_scope.dart';
import '../widgets/common_widgets.dart';

/// Displays debugger messages emitted by plugin tester operations.
class LogView extends StatelessWidget {
  /// Creates the log view.
  const LogView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MovesenseExampleScope.watch(context);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Debugger log',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Clear logs',
                onPressed: controller.logs.isEmpty
                    ? null
                    : controller.clearLogs,
                icon: const Icon(Icons.delete_sweep),
              ),
            ],
          ),
        ),
        Expanded(
          child: controller.logs.isEmpty
              ? const EmptyState(
                  icon: Icons.bug_report,
                  title: 'No log entries',
                  message: 'Plugin actions write here and to debug output.',
                )
              : ListView.separated(
                  itemCount: controller.logs.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final entry = controller.logs[index];
                    return ListTile(
                      dense: true,
                      title: SelectableText(entry.message),
                      subtitle: Text(entry.formattedTime),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
