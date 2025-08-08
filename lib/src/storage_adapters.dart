import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Conditional imports for platform-specific code
import 'package:flutter_persist_state/src/storage_adapters_shared_prefs.dart'
    if (dart.library.io) 'package:flutter_persist_state/src/storage_adapters_io.dart'
    if (dart.library.html) 'package:flutter_persist_state/src/storage_adapters_web.dart';

/// Abstract class for storage adapters
abstract class StorageAdapter {
  Future<void> save(String key, dynamic value);
  Future<dynamic> load(String key);
  Future<void> delete(String key);
  Future<bool> containsKey(String key);
  Future<void> clear();
}

/// SharedPreferences storage adapter
class SharedPreferencesAdapter implements StorageAdapter {
  late SharedPreferences _prefs;

  SharedPreferencesAdapter._();

  static Future<SharedPreferencesAdapter> create() async {
    final adapter = SharedPreferencesAdapter._();
    adapter._prefs = await SharedPreferences.getInstance();
    return adapter;
  }

  @override
  Future<void> save(String key, dynamic value) async {
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
  Future<dynamic> load(String key) async {
    if (_prefs.containsKey(key)) {
      final value = _prefs.get(key);
      if (value is String) {
        try {
          // Try to deserialize JSON
          return jsonDecode(value);
        } catch (e) {
          // Return as plain string if not JSON
          return value;
        }
      }
      return value;
    }
    return null;
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}

/// File-based storage adapter for larger data (non-web platforms)
class FileStorageAdapter implements StorageAdapter {
  final FileStorageAdapterImpl _impl;

  FileStorageAdapter._(this._impl);

  static Future<FileStorageAdapter> create(
      [String namespace = 'persist_state']) async {
    final impl = await FileStorageAdapterImpl.create(namespace);
    return FileStorageAdapter._(impl);
  }

  @override
  Future<void> save(String key, dynamic value) async {
    return _impl.save(key, value);
  }

  @override
  Future<dynamic> load(String key) async {
    return _impl.load(key);
  }

  @override
  Future<void> delete(String key) async {
    return _impl.delete(key);
  }

  @override
  Future<bool> containsKey(String key) async {
    return _impl.containsKey(key);
  }

  @override
  Future<void> clear() async {
    return _impl.clear();
  }
}
