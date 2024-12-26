import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LocalFileService {
  LocalFileService._privateConstructor();
  static final LocalFileService instance =
      LocalFileService._privateConstructor();

  Future<String> createFilePath(String userId, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final userDirectory = Directory("${directory.path}/$userId");

    if (!await userDirectory.exists()) {
      await userDirectory.create(recursive: true);
    }

    return "${userDirectory.path}/$fileName";
  }

  Future<void> deleteFile(String filePath) async {
    try {
      if (await fileExists(filePath)) {
        await File(filePath).delete();
        debugPrint("File deleted: $filePath");
      } else {
        debugPrint("File does not exist: $filePath");
      }
    } catch (e) {
      debugPrint("Error deleting file: $e");
      rethrow;
    }
  }

  Future<List<String>> listUserFiles(String userId) async {
    final directory = await getApplicationDocumentsDirectory();
    final userDirectory = Directory("${directory.path}/$userId");

    if (!await userDirectory.exists()) {
      return [];
    }

    final files = userDirectory.listSync();
    return files.whereType<File>().map((file) => file.path).toList();
  }

  Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    final exists = await file.exists();
    debugPrint("Checking file existence: $filePath - Exists: $exists");
    return file.exists();
  }
}
