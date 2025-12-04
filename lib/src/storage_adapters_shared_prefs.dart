import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementation of FileStorageAdapter using SharedPreferences for WASM
/// compatibility
class FileStorageAdapterImpl {
  FileStorageAdapterImpl._(this._namespace);

  late SharedPreferences _prefs;
  final String _namespace;

  static Future<FileStorageAdapterImpl> create([
    final String namespace = 'persist_state',
  ]) async {
    final adapter = FileStorageAdapterImpl._(namespace)
      .._prefs = await SharedPreferences.getInstance();
    return adapter;
  }

  String _getKey(final String key) => '${_namespace}_$key';

  Future<void> save(final String key, final Object? value) async {
    final storageKey = _getKey(key);
    final jsonString = jsonEncode(value);
    await _prefs.setString(storageKey, jsonString);
  }

  Future<dynamic> load(final String key) async {
    final storageKey = _getKey(key);
    final jsonString = _prefs.getString(storageKey);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString);
      } on Object {
        return null;
      }
    }
    return null;
  }

  Future<void> delete(final String key) async {
    final storageKey = _getKey(key);
    await _prefs.remove(storageKey);
  }

  Future<bool> containsKey(final String key) async {
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
