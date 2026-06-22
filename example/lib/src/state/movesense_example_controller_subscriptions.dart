// Contains subscription-specific controller behavior for the example app.
//
// Parts:
// - Active subscription lookup.
// - Subscription start, stop, and stop-all operations.

part of 'movesense_example_controller.dart';

/// Subscription operations for [MovesenseExampleController].
extension MovesenseExampleControllerSubscriptions
    on MovesenseExampleController {
  /// Returns whether [key] identifies an active subscription.
  bool isSubscriptionActive(String key) => _subscriptions.containsKey(key);

  /// Returns the latest notification body for [key].
  String latestSubscriptionData(String key) {
    return _subscriptionLatestData[key] ?? '';
  }

  /// Starts a stream subscription identified by [key].
  Future<void> startSubscription(
    String key,
    String uri,
    String contract,
  ) async {
    if (_subscriptions.containsKey(key)) return;

    final normalizedContract = contract.trim().isEmpty ? '{}' : contract.trim();
    _log('Starting subscription "$key" at $uri.');
    final subscription = _plugin
        .subscribe(uri, contract: normalizedContract)
        .listen(
          (body) {
            _subscriptionLatestData[key] = body;
            _lastError = null;
            _log('Subscription "$key" notification: ${shorten(body)}');
          },
          onError: (Object error, StackTrace stackTrace) {
            _recordError('Subscription "$key" failed', error, stackTrace);
          },
          onDone: () {
            _subscriptions.remove(key);
            _log('Subscription "$key" ended.');
          },
        );

    _subscriptions[key] = subscription;
    _subscriptionLatestData.putIfAbsent(key, () => '');
    _emitChange();
  }

  /// Stops an active subscription by [key].
  Future<void> stopSubscription(String key) async {
    final subscription = _subscriptions.remove(key);
    if (subscription == null) return;

    _log('Stopping subscription "$key".');
    await subscription.cancel();
    _log('Subscription "$key" stopped.');
    _emitChange();
  }

  /// Stops every active subscription.
  Future<void> stopAllSubscriptions() async {
    final keys = _subscriptions.keys.toList();
    for (final key in keys) {
      await stopSubscription(key);
    }
  }
}
