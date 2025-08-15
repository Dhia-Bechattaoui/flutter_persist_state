import 'dart:async';
import 'package:flutter_persist_state/src/storage_adapters.dart';

/// A lightweight state management solution with automatic persistence
class PersistState<T> {
  T _value;
  final String _key;
  StorageAdapter? _storage;
  final T _defaultValue;
  final bool _autoPersist;
  final Duration _debounceTime;

  Timer? _debounceTimer;
  final StreamController<T> _controller = StreamController<T>.broadcast();

  /// Creates a new PersistState instance
  ///
  /// [key] - Unique identifier for this state in storage
  /// [defaultValue] - Default value if no persisted value exists
  /// [storage] - Storage adapter to use (defaults to SharedPreferences)
  /// [autoPersist] - Whether to automatically persist changes
  /// [debounceTime] - Debounce time for auto-persistence (defaults to 500ms)
  PersistState({
    required String key,
    required T defaultValue,
    StorageAdapter? storage,
    bool autoPersist = true,
    Duration? debounceTime,
  })  : _key = key,
        _value = defaultValue,
        _defaultValue = defaultValue,
        _storage = storage,
        _autoPersist = autoPersist,
        _debounceTime = debounceTime ?? const Duration(milliseconds: 500);

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
    } catch (e) {
      // If loading fails, use default value
      _value = _defaultValue;
    }
  }

  /// Update the state value
  ///
  /// [newValue] - New value to set
  /// [persist] - Whether to persist this change (overrides autoPersist setting)
  Future<void> set(T newValue, {bool? persist}) async {
    if (_value == newValue) return;

    _value = newValue;
    _controller.add(_value);

    final shouldPersist = persist ?? _autoPersist;
    if (shouldPersist) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(_debounceTime, () => _persist());
    }
  }

  /// Update the state value using a function
  ///
  /// [updater] - Function that takes current value and returns new value
  /// [persist] - Whether to persist this change (overrides autoPersist setting)
  Future<void> update(T Function(T currentValue) updater,
      {bool? persist}) async {
    final newValue = updater(_value);
    await set(newValue, persist: persist);
  }

  /// Manually persist the current value to storage
  Future<void> persist() async {
    if (_storage == null) return;

    try {
      await _storage!.save(_key, _value);
    } catch (e) {
      // Handle persistence errors
      // ignore: avoid_print
      print('Failed to persist state for key $_key: $e');
    }
  }

  /// Load the value from storage
  Future<void> load() async {
    if (_storage == null) return;

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
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load state for key $_key: $e');
    }
  }

  /// Delete the persisted value
  Future<void> delete() async {
    if (_storage == null) return;

    try {
      await _storage!.delete(_key);
      _value = _defaultValue;
      _controller.add(_value);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to delete state for key $_key: $e');
    }
  }

  /// Reset to default value
  Future<void> reset() async {
    await set(_defaultValue);
  }

  /// Check if a value is persisted
  Future<bool> hasPersistedValue() async {
    if (_storage == null) return false;
    return await _storage!.containsKey(_key);
  }

  /// Dispose of resources
  void dispose() {
    _debounceTimer?.cancel();
    _controller.close();
  }

  void _persist() {
    persist();
  }
}

/// Extension to create PersistState instances more easily
extension PersistStateExtension<T> on T {
  /// Create a PersistState instance with this value as default
  PersistState<T> asPersistState({
    required String key,
    StorageAdapter? storage,
    bool autoPersist = true,
    Duration? debounceTime,
  }) {
    return PersistState<T>(
      key: key,
      defaultValue: this,
      storage: storage,
      autoPersist: autoPersist,
      debounceTime: debounceTime,
    );
  }
}
