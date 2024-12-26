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
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('$userId/$recordingType/$fileName');

      final uploadTask = storageRef.putFile(file);

      // Monitorowanie postępu
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((event) {
          final progress = (event.bytesTransferred / event.totalBytes) * 100;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;

      // Pobranie URL do pliku
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
    required String fileName,
  }) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('$userId/$recordingType/$fileName');
      await storageRef.delete();
      debugPrint('File deleted successfully.');
    } catch (e) {
      debugPrint('Error deleting file: $e');
      rethrow;
    }
  }
}
