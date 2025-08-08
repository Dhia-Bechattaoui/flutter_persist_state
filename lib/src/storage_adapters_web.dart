import 'dart:convert';
import 'package:web/web.dart' as web;

/// Implementation of FileStorageAdapter for web platforms
class FileStorageAdapterImpl {
  final String _namespace;

  FileStorageAdapterImpl._(this._namespace);

  static Future<FileStorageAdapterImpl> create(
      [String namespace = 'persist_state']) async {
    return FileStorageAdapterImpl._(namespace);
  }

  String _getKey(String key) {
    return '${_namespace}_$key';
  }

  Future<void> save(String key, dynamic value) async {
    final storageKey = _getKey(key);
    final jsonString = jsonEncode(value);
    web.window.localStorage.setItem(storageKey, jsonString);
  }

  Future<dynamic> load(String key) async {
    final storageKey = _getKey(key);
    final jsonString = web.window.localStorage.getItem(storageKey);
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
    web.window.localStorage.removeItem(storageKey);
  }

  Future<bool> containsKey(String key) async {
    final storageKey = _getKey(key);
    return web.window.localStorage.getItem(storageKey) != null;
  }

  Future<void> clear() async {
    final keysToRemove = <String>[];
    final length = web.window.localStorage.length;
    for (int i = 0; i < length; i++) {
      final key = web.window.localStorage.key(i);
      if (key != null && key.startsWith('${_namespace}_')) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      web.window.localStorage.removeItem(key);
    }
  }
}
