import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LocalFileService {
  LocalFileService._privateConstructor();
  static final LocalFileService instance =
      LocalFileService._privateConstructor();

  Future<String> createFilePath(
      String userId, String recordingType, String recordingTitle) async {
    final directory = await getApplicationDocumentsDirectory();
    final userDirectory = Directory("${directory.path}/$userId");

    if (!await userDirectory.exists()) {
      await userDirectory.create(recursive: true);
    }

    final fileName = _generateFileName(recordingType, recordingTitle);
    return "${userDirectory.path}/$fileName";
  }

  String _generateFileName(String recordingType, String recordingTitle) {
    final formattedType =
        recordingType[0].toUpperCase() + recordingType.substring(1);
    final match = RegExp(r'#(\d+)').firstMatch(recordingTitle);
    if (match == null) {
      throw Exception('Invalid recordingTitle format: $recordingTitle');
    }
    final number = match.group(1);
    return "$formattedType$number.wav";
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

  Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    final exists = await file.exists();
    debugPrint("Checking file existence: $filePath - Exists: $exists");
    return file.exists();
  }
}
