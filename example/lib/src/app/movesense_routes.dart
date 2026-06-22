// Contains the named route constants used by the Movesense tester app.
//
// Parts:
// - `MovesenseRoutes`, the shared route-name catalog.

/// Centralizes route names so tab pages and pushed routes use one contract.
class MovesenseRoutes {
  /// Route for the tabbed home screen.
  static const home = '/';

  /// Route for the selected-device detail screen.
  static const device = '/device';

  /// Route for the standalone request tester.
  static const requests = '/requests';

  /// Route for the standalone subscription tester.
  static const subscriptions = '/subscriptions';

  /// Route for the standalone debugger log.
  static const logs = '/logs';
}
