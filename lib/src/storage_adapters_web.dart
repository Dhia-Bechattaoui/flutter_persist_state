import 'dart:convert';
import 'package:web/web.dart' as web;

/// Implementation of FileStorageAdapter for web platforms
class FileStorageAdapterImpl {
  FileStorageAdapterImpl._(this._namespace);

  final String _namespace;

  static Future<FileStorageAdapterImpl> create([
    final String namespace = 'persist_state',
  ]) async => FileStorageAdapterImpl._(namespace);

  String _getKey(final String key) => '${_namespace}_$key';

  Future<void> save(final String key, final Object? value) async {
    final storageKey = _getKey(key);
    final jsonString = jsonEncode(value);
    web.window.localStorage.setItem(storageKey, jsonString);
  }

  Future<dynamic> load(final String key) async {
    final storageKey = _getKey(key);
    final jsonString = web.window.localStorage.getItem(storageKey);
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
    web.window.localStorage.removeItem(storageKey);
  }

  Future<bool> containsKey(final String key) async {
    final storageKey = _getKey(key);
    return web.window.localStorage.getItem(storageKey) != null;
  }

  Future<void> clear() async {
    final keysToRemove = <String>[];
    final length = web.window.localStorage.length;
    for (var i = 0; i < length; i++) {
      final key = web.window.localStorage.key(i);
      if (key != null && key.startsWith('${_namespace}_')) {
        keysToRemove.add(key);
      }
    }
    keysToRemove.forEach(web.window.localStorage.removeItem);
  }
}
