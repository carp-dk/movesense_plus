// Contains debugger-log data displayed by the example app.
//
// Parts:
// - `LogEntry`, a timestamped message model.

/// One entry in the in-app debugger log.
class LogEntry {
  /// Creates a log entry at [time] with a rendered [message].
  const LogEntry({required this.time, required this.message});

  /// Time the entry was recorded.
  final DateTime time;

  /// Human-readable message shown in the log tab.
  final String message;

  /// Time formatted for compact display in the log list.
  String get formattedTime {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    String threeDigits(int value) => value.toString().padLeft(3, '0');
    return '${twoDigits(time.hour)}:${twoDigits(time.minute)}:'
        '${twoDigits(time.second)}.${threeDigits(time.millisecond)}';
  }
}
