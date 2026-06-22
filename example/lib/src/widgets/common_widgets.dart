// Contains shared UI primitives for the Movesense tester example.
//
// Parts:
// - `StatusPill`, a compact status label.
// - `InlineError`, an inline error banner.
// - `EmptyState`, a centered empty-content message.
// - `KeyValueRow`, a compact label/value row.
// - `showExampleSnackBar`, a small snackbar helper.

import 'package:flutter/material.dart';

/// Compact status label with a leading Material icon.
class StatusPill extends StatelessWidget {
  /// Creates a status pill for [label].
  const StatusPill({required this.icon, required this.label, super.key});

  /// Icon shown before [label].
  final IconData icon;

  /// Text shown inside the pill.
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// Inline error banner used by scan, request, and subscription screens.
class InlineError extends StatelessWidget {
  /// Creates an error banner with [message].
  const InlineError({required this.message, super.key});

  /// Rendered error text.
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centered message for tabs and routes without data to show.
class EmptyState extends StatelessWidget {
  /// Creates an empty state with an [icon], [title], and explanatory [message].
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  /// Leading icon.
  final IconData icon;

  /// Main empty-state title.
  final String title;

  /// Supporting message.
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 40),
            const SizedBox(height: 12),
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              message,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Label/value row used in device and response detail cards.
class KeyValueRow extends StatelessWidget {
  /// Creates one [label] and [value] row.
  const KeyValueRow({required this.label, required this.value, super.key});

  /// Row label.
  final String label;

  /// Selectable row value.
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 84,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}

/// Shows a short snackbar message in the nearest [ScaffoldMessenger].
void showExampleSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
