import 'dart:async';

import 'package:flutter/foundation.dart';

import 'storage_adapters.dart';

/// A lightweight state management solution with automatic persistence
class PersistState<T> {
  /// Creates a new PersistState instance
  ///
  /// [key] - Unique identifier for this state in storage
  /// [defaultValue] - Default value if no persisted value exists
  /// [storage] - Storage adapter to use (defaults to SharedPreferences)
  /// [autoPersist] - Whether to automatically persist changes
  /// [debounceTime] - Debounce time for auto-persistence (defaults to 500ms)
  PersistState({
    required final String key,
    required final T defaultValue,
    final StorageAdapter? storage,
    final bool autoPersist = true,
    final Duration? debounceTime,
  }) : _key = key,
       _value = defaultValue,
       _defaultValue = defaultValue,
       _storage = storage,
       _autoPersist = autoPersist,
       _debounceTime = debounceTime ?? const Duration(milliseconds: 500);
  T _value;
  final String _key;
  StorageAdapter? _storage;
  final T _defaultValue;
  final bool _autoPersist;
  final Duration _debounceTime;

  Timer? _debounceTimer;
  final StreamController<T> _controller = StreamController<T>.broadcast();

  /// Current value of the state
  T get value => _value;

  /// Stream of value changes
  Stream<T> get stream => _controller.stream;

  /// Initialize the state by loading from storage
  Future<void> initialize() async {
    // Initialize storage if not provided
    _storage ??= await SharedPreferencesAdapter.create();

    try {
      final storedValue = await _storage!.load(_key);
      if (storedValue != null) {
        // Safe type checking before assignment
        if (storedValue is T) {
          _value = storedValue;
          _controller.add(_value);
        } else {
          // Type mismatch, use default value
          _value = _defaultValue;
        }
      }
    } on Object {
      // If loading fails, use default value
      _value = _defaultValue;
    }
  }

  /// Update the state value
  ///
  /// [newValue] - New value to set
  /// [persist] - Whether to persist this change (overrides autoPersist setting)
  Future<void> set(final T newValue, {final bool? persist}) async {
    if (_value == newValue) {
      return;
    }

    _value = newValue;
    _controller.add(_value);

    final shouldPersist = persist ?? _autoPersist;
    if (shouldPersist) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(_debounceTime, _persist);
    }
  }

  /// Update the state value using a function
  ///
  /// [updater] - Function that takes current value and returns new value
  /// [persist] - Whether to persist this change (overrides autoPersist setting)
  Future<void> update(
    final T Function(T currentValue) updater, {
    final bool? persist,
  }) async {
    final newValue = updater(_value);
    await set(newValue, persist: persist);
  }

  /// Manually persist the current value to storage
  Future<void> persist() async {
    if (_storage == null) {
      return;
    }

    try {
      await _storage!.save(_key, _value);
    } on Object catch (e) {
      // Handle persistence errors
      debugPrint('Failed to persist state for key $_key: $e');
    }
  }

  /// Load the value from storage
  Future<void> load() async {
    if (_storage == null) {
      return;
    }

    try {
      final storedValue = await _storage!.load(_key);
      if (storedValue != null) {
        // Safe type checking before assignment
        if (storedValue is T) {
          _value = storedValue;
          _controller.add(_value);
        } else {
          // Type mismatch, use default value
          _value = _defaultValue;
        }
      }
    } on Object catch (e) {
      debugPrint('Failed to load state for key $_key: $e');
    }
  }

  /// Delete the persisted value
  Future<void> delete() async {
    if (_storage == null) {
      return;
    }

    try {
      await _storage!.delete(_key);
      _value = _defaultValue;
      _controller.add(_value);
    } on Object catch (e) {
      debugPrint('Failed to delete state for key $_key: $e');
    }
  }

  /// Reset to default value
  Future<void> reset() async => set(_defaultValue);

  /// Check if a value is persisted
  Future<bool> hasPersistedValue() async {
    if (_storage == null) {
      return false;
    }
    return _storage!.containsKey(_key);
  }

  /// Dispose of resources
  void dispose() {
    _debounceTimer?.cancel();
    unawaited(_controller.close());
  }

  void _persist() {
    // Fire and forget - persistence errors are handled in persist()
    unawaited(persist());
  }
}

/// Extension to create PersistState instances more easily
extension PersistStateExtension<T> on T {
  /// Create a PersistState instance with this value as default
  PersistState<T> asPersistState({
    required final String key,
    final StorageAdapter? storage,
    final bool autoPersist = true,
    final Duration? debounceTime,
  }) => PersistState<T>(
    key: key,
    defaultValue: this,
    storage: storage,
    autoPersist: autoPersist,
    debounceTime: debounceTime,
  );
}
