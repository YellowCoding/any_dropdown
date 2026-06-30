import 'dart:async';

import 'package:flutter/foundation.dart';

/// The current state of dropdown options.
///
/// Tracks the available [options], whether they are [loading], and any
/// [error] from the last fetch. Call [reset] to clear all fields.
class AnyDropdownOptionState<T> {
  AnyDropdownOptionState({
    this.options = const [],
    this.loading = false,
    this.error,
  });

  /// The list of available options.
  List<T> options;

  /// Whether options are currently being fetched asynchronously.
  bool loading;

  /// An error that occurred during the last fetch, if any.
  Object? error;

  /// Resets all fields to their initial empty state.
  void reset() {
    options = const [];
    loading = false;
    error = null;
  }
}

/// Manages the dropdown option list via [ChangeNotifier].
///
/// Supports both synchronous and asynchronous option fetching through
/// [optionsFetcher]. Call [refreshOptions] to load or reload options.
///
/// ```dart
/// // Synchronous options
/// final provider = AnyDropdownOptionProvider<String>(
///   optionsFetcher: () => ['A', 'B', 'C'],
/// )..refreshOptions();
///
/// // Asynchronous options
/// final provider = AnyDropdownOptionProvider<String>(
///   optionsFetcher: () async {
///     await Future.delayed(const Duration(seconds: 1));
///     return ['New York', 'London', 'Tokyo'];
///   },
/// )..refreshOptions();
/// ```
class AnyDropdownOptionProvider<T> extends ChangeNotifier {
  AnyDropdownOptionProvider({required this.optionsFetcher});

  /// The current option state.
  AnyDropdownOptionState<T> get state => _state;
  final AnyDropdownOptionState<T> _state = AnyDropdownOptionState();

  /// Returns the list of options, synchronously or asynchronously.
  final FutureOr<List<T>> Function() optionsFetcher;

  /// Reloads the options by calling [optionsFetcher].
  ///
  /// If [resetState] is `true`, the state is cleared before fetching.
  ///
  /// For async fetchers, sets `loading` to `true`, notifies listeners,
  /// then updates [AnyDropdownOptionState.options] and
  /// [AnyDropdownOptionState.error] on completion. For sync fetchers,
  /// assigns the result immediately and notifies listeners.
  FutureOr<void> refreshOptions({bool resetState = false}) async {
    if (resetState) {
      _state.reset();
    }
    try {
      final future = optionsFetcher();
      if (future is Future<List<T>>) {
        _state.loading = true;
        notifyListeners();

        final options = await future;
        _state.options = options;
      } else {
        _state.options = future;
      }
    } catch (e) {
      _state.error = e;
      notifyListeners();
    } finally {
      _state.loading = false;
      notifyListeners();
    }
  }
}
