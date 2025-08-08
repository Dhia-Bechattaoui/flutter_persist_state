import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementation of FileStorageAdapter using SharedPreferences for WASM compatibility
class FileStorageAdapterImpl {
  late SharedPreferences _prefs;
  final String _namespace;

  FileStorageAdapterImpl._(this._namespace);

  static Future<FileStorageAdapterImpl> create(
      [String namespace = 'persist_state']) async {
    final adapter = FileStorageAdapterImpl._(namespace);
    adapter._prefs = await SharedPreferences.getInstance();
    return adapter;
  }

  String _getKey(String key) {
    return '${_namespace}_$key';
  }

  Future<void> save(String key, dynamic value) async {
    final storageKey = _getKey(key);
    final jsonString = jsonEncode(value);
    await _prefs.setString(storageKey, jsonString);
  }

  Future<dynamic> load(String key) async {
    final storageKey = _getKey(key);
    final jsonString = _prefs.getString(storageKey);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> delete(String key) async {
    final storageKey = _getKey(key);
    await _prefs.remove(storageKey);
  }

  Future<bool> containsKey(String key) async {
    final storageKey = _getKey(key);
    return _prefs.containsKey(storageKey);
  }

  Future<void> clear() async {
    final keysToRemove = <String>[];
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('${_namespace}_')) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      await _prefs.remove(key);
    }
  }
}
