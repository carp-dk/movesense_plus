// Contains quick-test behavior for the example controller.
//
// Parts:
// - Temperature read with GET and subscription fallback.
// - LED write quick test.

part of 'movesense_example_controller.dart';

/// Quick-test operations for [MovesenseExampleController].
extension MovesenseExampleControllerQuickTests on MovesenseExampleController {
  /// Reads temperature and stores a Celsius quick-test result.
  Future<void> readTemperature(String serial) async {
    _quickResults['temperature'] = 'Reading...';
    _emitChange();

    final response = await sendRequest(
      MdsRequestMethod.get,
      Mds.createRequestUri(serial, '/Meas/Temp'),
      '{}',
    );
    if (_storeTemperatureBody(response?.body)) return;

    _log('Temperature GET unavailable; sampling /Meas/Temp subscription.');
    final sampleBody = await _sampleTemperatureSubscription(serial);
    if (_storeTemperatureBody(sampleBody)) return;

    _quickResults['temperature'] = 'No temperature measurement available.';
    _emitChange();
  }

  /// Writes the Movesense LED state through MDS.
  Future<void> setLed(String serial, bool enabled) async {
    final response = await sendRequest(
      MdsRequestMethod.put,
      Mds.createRequestUri(serial, '/Component/Led'),
      jsonEncode(<String, bool>{'isOn': enabled}),
    );
    if (response == null) return;

    _ledOn = enabled;
    _quickResults['led'] = enabled ? 'LED on' : 'LED off';
    _emitChange();
  }

  /// Parses and stores a temperature response body when it contains a reading.
  bool _storeTemperatureBody(String? body) {
    final kelvin = _extractTemperatureKelvin(body);
    if (kelvin == null) return false;

    final celsius = kelvin - 273.15;
    _quickResults['temperature'] = '${celsius.toStringAsFixed(1)} C';
    _lastError = null;
    _emitChange();
    return true;
  }

  /// Extracts Kelvin from either GET or subscription notification JSON.
  num? _extractTemperatureKelvin(String? body) {
    if (body == null || body.isEmpty) return null;
    final decoded = decodeJsonMap(body);
    final content = decoded['Content'];
    final notificationBody = decoded['Body'];
    final contentMeasurement = content is Map ? content['Measurement'] : null;
    final bodyMeasurement = notificationBody is Map
        ? notificationBody['Measurement']
        : null;

    if (contentMeasurement is num) return contentMeasurement;
    if (bodyMeasurement is num) return bodyMeasurement;
    return null;
  }

  /// Waits briefly for one `/Meas/Temp` subscription notification.
  Future<String?> _sampleTemperatureSubscription(String serial) async {
    final completer = Completer<String>();
    StreamSubscription<String>? subscription;
    Timer? timeout;

    try {
      subscription = _plugin
          .subscribe(Mds.createSubscriptionUri(serial, '/Meas/Temp'))
          .listen(
            (body) {
              if (!completer.isCompleted) completer.complete(body);
            },
            onError: (Object error, StackTrace stackTrace) {
              if (!completer.isCompleted) {
                completer.completeError(error, stackTrace);
              }
            },
          );
      timeout = Timer(const Duration(seconds: 6), () {
        if (!completer.isCompleted) {
          completer.completeError(
            TimeoutException('No temperature notification received.'),
          );
        }
      });

      final body = await completer.future;
      _log('Temperature subscription sample received: ${shorten(body)}');
      return body;
    } catch (error, stackTrace) {
      _recordError('Temperature subscription sample failed', error, stackTrace);
      return null;
    } finally {
      timeout?.cancel();
      await subscription?.cancel();
    }
  }
}
