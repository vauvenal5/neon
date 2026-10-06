import 'dart:async';

import 'package:flutter/material.dart';
import 'package:neon_framework/src/models/disposable.dart';

/// Result returned by an action to tell the framework whether to clear selection.
enum NeonMultiSelectActionResult {
  /// The action completed and the selected items can be cleared.
  clearSelection,

  /// The action was canceled or otherwise left the selection unchanged.
  keepSelection,
}

/// An action displayed for a framework-owned multi-selection.
abstract class NeonSelectAction {
  /// Creates a multi-selection action.
  const NeonSelectAction();

  /// Builds the action label for the current locale.
  String label(BuildContext context);

  /// Handles this action and reports whether the framework should clear selection.
  FutureOr<NeonMultiSelectActionResult> onSelected(BuildContext context);

  /// Whether this action should be included for the current selection.
  bool mayRender() => true;

  /// Optional icon shown alongside the action label.
  IconData? get icon => null;
}

/// The non-generic selection surface consumed by the framework app bar.
abstract interface class NeonMultiSelectSession implements Listenable {
  /// Number of currently selected items.
  int get selectedCount;

  /// Actions available for the current selection.
  List<NeonSelectAction> get actions;

  /// Clears the current selection.
  void clear();
}

/// Tracks typed selected items while exposing a common interface to Neon UI.
class NeonMultiSelectController<T> extends ChangeNotifier implements NeonMultiSelectSession, Disposable {
  /// Creates a controller using [keyOf] to identify items across rebuilds.
  NeonMultiSelectController({
    required Object Function(T item) keyOf,
    required List<NeonSelectAction> Function(List<T> selectedItems) actionsBuilder,
  })  : _keyOf = keyOf,
        _actionsBuilder = actionsBuilder;

  final Object Function(T item) _keyOf;
  final List<NeonSelectAction> Function(List<T> selectedItems) _actionsBuilder;
  final Map<Object, T> _selected = {};

  /// Whether any items are selected.
  bool get isNotEmpty => _selected.isNotEmpty;

  /// Whether no items are selected.
  bool get isEmpty => _selected.isEmpty;

  /// Number of currently selected items.
  @override
  int get selectedCount => _selected.length;

  /// A snapshot of the selected typed items in selection order.
  List<T> get selectedItems => List.unmodifiable(_selected.values);

  /// Actions supplied for the current selection, filtered by each action's eligibility rule.
  @override
  List<NeonSelectAction> get actions => List.unmodifiable(_actionsBuilder(selectedItems));

  /// Whether [item] is selected, based on its stable key.
  bool isSelected(T item) => _selected.containsKey(_keyOf(item));

  /// Toggles [item].
  void toggle(T item) {
    final key = _keyOf(item);
    if (_selected.containsKey(key)) {
      _selected.remove(key);
    } else {
      _selected[key] = item;
    }
    notifyListeners();
  }

  /// Clears all selected items.
  @override
  void clear() {
    if (isEmpty) {
      return;
    }

    _selected.clear();
    notifyListeners();
  }
}
