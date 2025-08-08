import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Implementation of FileStorageAdapter for non-web platforms
class FileStorageAdapterImpl {
  late Directory _directory;
  final String _namespace;

  FileStorageAdapterImpl._(this._namespace);

  static Future<FileStorageAdapterImpl> create(
      [String namespace = 'persist_state']) async {
    final adapter = FileStorageAdapterImpl._(namespace);
    final appDir = await getApplicationDocumentsDirectory();
    adapter._directory = Directory('${appDir.path}/$namespace');
    if (!await adapter._directory.exists()) {
      await adapter._directory.create(recursive: true);
    }
    return adapter;
  }

  File _getFile(String key) {
    return File('${_directory.path}/${_namespace}_$key.json');
  }

  Future<void> save(String key, dynamic value) async {
    final file = _getFile(key);
    final jsonString = jsonEncode(value);
    await file.writeAsString(jsonString);
  }

  Future<dynamic> load(String key) async {
    final file = _getFile(key);
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      return jsonDecode(jsonString);
    }
    return null;
  }

  Future<void> delete(String key) async {
    final file = _getFile(key);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<bool> containsKey(String key) async {
    final file = _getFile(key);
    return await file.exists();
  }

  Future<void> clear() async {
    if (await _directory.exists()) {
      await _directory.delete(recursive: true);
      await _directory.create();
    }
  }
}
