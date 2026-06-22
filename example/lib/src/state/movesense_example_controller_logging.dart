// Contains debugger logging behavior for the example controller.
//
// Parts:
// - Error rendering for `MdsError` and generic failures.
// - In-app log collection.
// - `developer.log` and `debugPrint` output.

part of 'movesense_example_controller.dart';

/// Logging operations for [MovesenseExampleController].
extension MovesenseExampleControllerLogging on MovesenseExampleController {
  /// Clears all visible log entries and records that action.
  void clearLogs() {
    _logs.clear();
    _log('Logs cleared.');
  }

  /// Records a plugin or stream error.
  void _recordError(String message, Object error, StackTrace stackTrace) {
    final rendered = error is MdsError
        ? '${error.error} (status ${error.status})'
        : error.toString();
    _lastError = rendered;
    _addLog('$message: $rendered', error: error, stackTrace: stackTrace);
    _emitChange();
  }

  /// Records an informational debugger message.
  void _log(String message) {
    _addLog(message);
    _emitChange();
  }

  /// Stores and emits [message] through debugger logging channels.
  void _addLog(String message, {Object? error, StackTrace? stackTrace}) {
    final entry = LogEntry(time: DateTime.now(), message: message);
    _logs.insert(0, entry);
    if (_logs.length > 200) {
      _logs.removeRange(200, _logs.length);
    }

    developer.log(
      message,
      name: 'carp.movesense.example',
      error: error,
      stackTrace: stackTrace,
    );
    debugPrint('[MovesenseExample] $message');
  }
}
