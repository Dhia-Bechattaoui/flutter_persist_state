import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// Conditional imports for platform-specific code
import 'storage_adapters_shared_prefs.dart'
    if (dart.library.io) 'storage_adapters_io.dart'
    if (dart.library.html) 'storage_adapters_web.dart';

/// Abstract class for storage adapters
abstract class StorageAdapter {
  Future<void> save(final String key, final Object? value);
  Future<dynamic> load(final String key);
  Future<void> delete(final String key);
  Future<bool> containsKey(final String key);
  Future<void> clear();
}

/// SharedPreferences storage adapter
class SharedPreferencesAdapter implements StorageAdapter {
  SharedPreferencesAdapter._();

  late SharedPreferences _prefs;

  static Future<SharedPreferencesAdapter> create() async {
    final adapter = SharedPreferencesAdapter._()
      .._prefs = await SharedPreferences.getInstance();
    return adapter;
  }

  @override
  Future<void> save(final String key, final Object? value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    } else {
      // For complex objects, serialize to JSON
      await _prefs.setString(key, jsonEncode(value));
    }
  }

  @override
  Future<dynamic> load(final String key) async {
    if (_prefs.containsKey(key)) {
      final value = _prefs.get(key);
      if (value is String) {
        try {
          // Try to deserialize JSON
          return jsonDecode(value);
        } on Object {
          // Return as plain string if not JSON
          return value;
        }
      }
      return value;
    }
    return null;
  }

  @override
  Future<void> delete(final String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<bool> containsKey(final String key) async => _prefs.containsKey(key);

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}

/// File-based storage adapter for larger data (non-web platforms)
class FileStorageAdapter implements StorageAdapter {
  FileStorageAdapter._(this._impl);

  final FileStorageAdapterImpl _impl;

  /// Creates a new FileStorageAdapter instance
  ///
  /// [namespace] - Namespace for file storage (defaults to 'persist_state')
  static Future<FileStorageAdapter> create([
    final String namespace = 'persist_state',
  ]) async {
    final impl = await FileStorageAdapterImpl.create(namespace);
    return FileStorageAdapter._(impl);
  }

  @override
  Future<void> save(final String key, final Object? value) async =>
      _impl.save(key, value);

  @override
  Future<dynamic> load(final String key) async => _impl.load(key);

  /// Delete a value from storage
  ///
  /// [key] - The key to delete
  @override
  Future<void> delete(final String key) async => _impl.delete(key);

  /// Check if a key exists in storage
  ///
  /// [key] - The key to check
  /// Returns true if the key exists, false otherwise
  @override
  Future<bool> containsKey(final String key) async => _impl.containsKey(key);

  /// Clear all values from storage
  @override
  Future<void> clear() async => _impl.clear();
}
