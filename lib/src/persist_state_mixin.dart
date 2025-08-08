import 'package:flutter/material.dart';
import 'package:flutter_persist_state/src/persist_state.dart';
import 'package:flutter_persist_state/src/storage_adapters.dart';

/// Mixin for StatefulWidget to easily manage persistent state
mixin PersistStateMixin<T extends StatefulWidget> on State<T> {
  final Map<String, PersistState<dynamic>> _persistStates = {};
  bool _initialized = false;

  /// Get or create a persistent state
  ///
  /// [key] - Unique identifier for this state
  /// [defaultValue] - Default value if no persisted value exists
  /// [storage] - Storage adapter to use
  /// [autoPersist] - Whether to automatically persist changes
  /// [debounceTime] - Debounce time for auto-persistence
  PersistState<R> getPersistState<R>({
    required String key,
    required R defaultValue,
    StorageAdapter? storage,
    bool autoPersist = true,
    Duration? debounceTime,
  }) {
    if (!_persistStates.containsKey(key)) {
      final persistState = PersistState<R>(
        key: key,
        defaultValue: defaultValue,
        storage: storage,
        autoPersist: autoPersist,
        debounceTime: debounceTime,
      );
      _persistStates[key] = persistState;

      // Listen to changes and rebuild widget
      persistState.stream.listen((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }

    return _persistStates[key] as PersistState<R>;
  }

  /// Initialize all persistent states
  Future<void> initializePersistStates() async {
    if (_initialized) return;

    for (final persistState in _persistStates.values) {
      await persistState.initialize();
    }
    _initialized = true;
  }

  /// Get a simple persistent value (creates state if needed)
  R getPersistValue<R>({
    required String key,
    required R defaultValue,
    StorageAdapter? storage,
    bool autoPersist = true,
    Duration? debounceTime,
  }) {
    return getPersistState<R>(
      key: key,
      defaultValue: defaultValue,
      storage: storage,
      autoPersist: autoPersist,
      debounceTime: debounceTime,
    ).value;
  }

  /// Set a persistent value
  Future<void> setPersistValue<R>({
    required String key,
    required R value,
    required R defaultValue,
    StorageAdapter? storage,
    bool autoPersist = true,
    Duration? debounceTime,
    bool? persist,
  }) async {
    await getPersistState<R>(
      key: key,
      defaultValue: defaultValue,
      storage: storage,
      autoPersist: autoPersist,
      debounceTime: debounceTime,
    ).set(value, persist: persist);
  }

  /// Update a persistent value using a function
  Future<void> updatePersistValue<R>({
    required String key,
    required R Function(R currentValue) updater,
    required R defaultValue,
    StorageAdapter? storage,
    bool autoPersist = true,
    Duration? debounceTime,
    bool? persist,
  }) async {
    await getPersistState<R>(
      key: key,
      defaultValue: defaultValue,
      storage: storage,
      autoPersist: autoPersist,
      debounceTime: debounceTime,
    ).update(updater, persist: persist);
  }

  /// Delete a persistent value
  Future<void> deletePersistValue(String key) async {
    if (_persistStates.containsKey(key)) {
      await _persistStates[key]!.delete();
    }
  }

  /// Reset a persistent value to default
  Future<void> resetPersistValue(String key) async {
    if (_persistStates.containsKey(key)) {
      await _persistStates[key]!.reset();
    }
  }

  /// Clear all persistent values
  Future<void> clearAllPersistValues() async {
    for (final persistState in _persistStates.values) {
      await persistState.delete();
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize persistent states after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializePersistStates();
    });
  }

  @override
  void dispose() {
    // Dispose all persistent states
    for (final persistState in _persistStates.values) {
      persistState.dispose();
    }
    _persistStates.clear();
    super.dispose();
  }
}
