// Contains the inherited controller scope used by the example widget tree.
//
// Parts:
// - `MovesenseExampleScope`, a small dependency access wrapper.

import 'package:flutter/widgets.dart';

export 'movesense_example_controller.dart';

import 'movesense_example_controller.dart';

/// Exposes the singleton example controller to route and tab widgets.
class MovesenseExampleScope
    extends InheritedNotifier<MovesenseExampleController> {
  /// Creates a scope for [controller] and the provided subtree.
  const MovesenseExampleScope({
    required this.controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  /// Controller shared by the example app.
  final MovesenseExampleController controller;

  /// Reads the controller and rebuilds when it notifies listeners.
  static MovesenseExampleController watch(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<MovesenseExampleScope>();
    assert(scope != null, 'MovesenseExampleScope was not found.');
    return scope!.controller;
  }

  /// Reads the controller without subscribing the caller to rebuilds.
  static MovesenseExampleController read(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<MovesenseExampleScope>();
    final scope = element?.widget as MovesenseExampleScope?;
    assert(scope != null, 'MovesenseExampleScope was not found.');
    return scope!.controller;
  }
}
