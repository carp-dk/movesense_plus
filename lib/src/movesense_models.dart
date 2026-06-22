/// Supported REST-style MDS request methods.
enum MdsRequestMethod {
  get('GET'),
  put('PUT'),
  post('POST'),
  delete('DELETE');

  const MdsRequestMethod(this.nativeName);

  /// Method name expected by the native Movesense SDK adapters.
  final String nativeName;
}

/// A Movesense peripheral discovered by BLE scanning.
class MovesenseDevice {
  const MovesenseDevice({this.name, required this.address});

  /// BLE advertisement name, when available.
  final String? name;

  /// Bluetooth MAC address on Android and UUID string on Apple platforms.
  final String address;
}

/// BLE and MDS connection lifecycle states reported by native code.
enum MovesenseConnectionEventType { bleConnected, connected, disconnected, error }

/// A connection lifecycle event for a Movesense peripheral.
class MovesenseConnectionEvent {
  const MovesenseConnectionEvent({required this.type, this.address, this.serial, this.error});

  final MovesenseConnectionEventType type;
  final String? address;
  final String? serial;
  final String? error;
}

/// A completed MDS request or subscription acknowledgement.
class MdsResponse {
  const MdsResponse({required this.body, required this.statusCode});

  /// JSON response body from MDS. Empty responses are represented as an empty string.
  final String body;

  /// HTTP-like status code reported by the native Movesense SDK.
  final int statusCode;
}

/// Error type used by both callback and Future based APIs.
class MdsError implements Exception {
  const MdsError(this.status, this.error);

  /// HTTP-like status code reported by MDS, or zero for local/native failures.
  final int status;

  /// Human-readable error reason.
  final String error;

  @override
  String toString() {
    return 'MdsError(status: $status, error: $error)';
  }
}

typedef MdsSuccessCallback = void Function(MdsResponse response);
typedef MdsErrorCallback = void Function(MdsError error);
typedef MdsNotificationCallback = void Function(String body);
