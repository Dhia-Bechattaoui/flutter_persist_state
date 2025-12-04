import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Implementation of FileStorageAdapter for non-web platforms
class FileStorageAdapterImpl {
  FileStorageAdapterImpl._(this._namespace);

  late Directory _directory;
  final String _namespace;

  static Future<FileStorageAdapterImpl> create([
    final String namespace = 'persist_state',
  ]) async {
    final adapter = FileStorageAdapterImpl._(namespace);
    final appDir = await getApplicationDocumentsDirectory();
    adapter._directory = Directory('${appDir.path}/$namespace');
    final dirPath = adapter._directory.path;
    final exists = await compute(_checkDirectoryExists, dirPath);
    if (!exists) {
      await compute(_createDirectory, dirPath);
    }
    return adapter;
  }

  static bool _checkDirectoryExists(final String path) =>
      Directory(path).existsSync();

  static void _createDirectory(final String path) =>
      Directory(path).createSync(recursive: true);

  File _getFile(final String key) =>
      File('${_directory.path}/${_namespace}_$key.json');

  Future<void> save(final String key, final Object? value) async {
    final file = _getFile(key);
    final jsonString = jsonEncode(value);
    await file.writeAsString(jsonString);
  }

  Future<dynamic> load(final String key) async {
    final filePath = _getFile(key).path;
    final exists = await compute(_checkFileExists, filePath);
    if (exists) {
      final jsonString = await compute(_readFile, filePath);
      return jsonDecode(jsonString);
    }
    return null;
  }

  static bool _checkFileExists(final String path) => File(path).existsSync();

  static String _readFile(final String path) => File(path).readAsStringSync();

  Future<void> delete(final String key) async {
    final filePath = _getFile(key).path;
    final exists = await compute(_checkFileExists, filePath);
    if (exists) {
      await compute(_deleteFile, filePath);
    }
  }

  static void _deleteFile(final String path) => File(path).deleteSync();

  Future<bool> containsKey(final String key) async {
    final filePath = _getFile(key).path;
    return compute(_checkFileExists, filePath);
  }

  Future<void> clear() async {
    final dirPath = _directory.path;
    final exists = await compute(_checkDirectoryExists, dirPath);
    if (exists) {
      await compute(_clearDirectory, dirPath);
    }
  }

  static void _clearDirectory(final String path) {
    Directory(path).deleteSync(recursive: true);
    Directory(path).createSync();
  }
}
