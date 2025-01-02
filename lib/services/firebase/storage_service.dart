import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StorageService {
  StorageService._privateConstructor();
  static final StorageService instance = StorageService._privateConstructor();

  Future<String> uploadAudioFile({
    required File file,
    required String userId,
    required String recordingType,
    required String recordingTitle,
    Function(double)? onProgress,
  }) async {
    try {
      final fileName = _convertTitleToFileName(recordingTitle);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('$userId/${recordingType}s/$fileName');

      final uploadTask = storageRef.putFile(file);

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((event) {
          final progress = (event.bytesTransferred / event.totalBytes) * 100;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;

      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('File uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      rethrow;
    }
  }

  Future<void> deleteAudioFile({
    required String userId,
    required String recordingType,
    required String recordingTitle,
  }) async {
    try {
      final fileName = _convertTitleToFileName(recordingTitle);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('$userId/${recordingType}s/$fileName');
      await storageRef.delete();
      debugPrint('File deleted successfully.');
    } catch (e) {
      debugPrint('Error deleting file: $e');
      rethrow;
    }
  }

  String _convertTitleToFileName(String title) {
    if (title.startsWith('Próbka')) {
      final number = title.split('#').last.trim();
      return 'IndividualSample$number.wav';
    } else if (title.startsWith('Hasło współdzielone')) {
      final number = title.split('#').last.trim();
      return 'SharedPassword$number.wav';
    } else if (title.startsWith('Hasło')) {
      final number = title.split('#').last.trim();
      return 'IndividualPassword$number.wav';
    }
    throw Exception('Nieznany format tytułu: $title');
  }
}
