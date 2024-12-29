import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../logging_service.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  FirestoreService._privateConstructor();
  static final FirestoreService instance =
      FirestoreService._privateConstructor();

  Future<List<UserModel>> fetchUsers() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      LoggingService.instance.log(
          'Fetched ${snapshot.docs.length} users from Firestore.',
          level: 'info');
      return snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList();
    } catch (e) {
      LoggingService.instance.log('Failed to fetch users: $e', level: 'error');
      rethrow;
    }
  }

  Future<void> addUser({required String name, required String email}) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc();
      final userData = {
        'displayName': name,
        'email': email,
        'recordingCounts': {
          'individualSamples': 0,
          'individualPasswords': 0,
          'sharedPasswords': 0,
        },
        'createdAt': Timestamp.now(),
      };

      await userDoc.set(userData);
      LoggingService.instance
          .log('User added successfully: $name ($email)', level: 'info');
    } catch (e) {
      LoggingService.instance.log('Failed to add user: $e', level: 'error');
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      final recordingsRef = userRef.collection('recordings');

      final recordingsSnapshot = await recordingsRef.get();

      for (final doc in recordingsSnapshot.docs) {
        await doc.reference.delete();
      }

      await userRef.delete();

      LoggingService.instance.log(
        'User with ID $userId and all related recordings deleted successfully.',
        level: 'info',
      );
    } catch (e) {
      LoggingService.instance.log(
        'Failed to delete user $userId and related recordings: $e',
        level: 'error',
      );
      rethrow;
    }
  }

  Future<bool> isEmailRegistered(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      final isRegistered = snapshot.docs.isNotEmpty;
      LoggingService.instance.log(
          'Checked if email "$email" is registered: $isRegistered',
          level: 'info');
      return isRegistered;
    } catch (e) {
      LoggingService.instance
          .log('Failed to check email registration: $e', level: 'error');
      rethrow;
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchRecordings(
      String userId) async {
    try {
      final Map<String, List<Map<String, dynamic>>> recordings = {
        'individualSamples': [],
        'individualPasswords': [],
        'sharedPasswords': [],
      };

      final Map<String, int> recordingTypes = {
        'individualSamples': 3,
        'individualPasswords': 5,
        'sharedPasswords': 5,
      };

      final recordingsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('recordings');

      final snapshot = await recordingsRef.get();

      recordingTypes.forEach((type, countValue) {
        recordings[type] = List.generate(
          countValue,
          (index) => {
            'title': _getTitle(type, '$type${index + 1}'),
            'subtitle': 'Brak daty',
            'duration': '0',
            'isRecorded': false,
          },
        );
      });

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final String docId = doc.id;

        String? type;
        if (docId.startsWith('IndividualSample')) {
          type = 'individualSamples';
        } else if (docId.startsWith('IndividualPassword')) {
          type = 'individualPasswords';
        } else if (docId.startsWith('SharedPassword')) {
          type = 'sharedPasswords';
        }

        if (type != null) {
          final int number = _extractNumber(docId);

          if (number > 0 && number <= recordingTypes[type]!) {
            recordings[type]![number - 1] = {
              'title': _getTitle(type, docId),
              'subtitle': data['uploadedAt'] != null
                  ? _formatDate((data['uploadedAt'] as Timestamp).toDate())
                  : 'Brak daty',
              'duration': data['duration']?.toString() ?? '0',
              'isRecorded': true,
            };
          }
        }
      }

      return recordings;
    } catch (e) {
      debugPrint('Błąd podczas fetchowania nagrań: $e');
      return {
        'individualSamples': [],
        'individualPasswords': [],
        'sharedPasswords': [],
      };
    }
  }

  Future<void> addRecording({
    required String userId,
    required String type,
    required String filePath,
    required Timestamp uploadedAt,
    required int duration,
    required String recordingTitle,
  }) async {
    try {
      final fileName = _convertTitleToFileName(recordingTitle);

      final recordingDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('recordings')
          .doc(fileName);

      final recordingData = {
        'type': type,
        'filePath': filePath,
        'uploadedAt': uploadedAt,
        'duration': duration,
      };

      await recordingDocRef.set(recordingData);

      LoggingService.instance.log(
          'Recording $fileName added successfully for user $userId.',
          level: 'info');
    } catch (e) {
      LoggingService.instance
          .log('Failed to add document for user $userId: $e', level: 'error');
      rethrow;
    }
  }

  /// Usuwanie nagrania
  Future<void> deleteRecording({
    required String userId,
    required String recordingTitle,
  }) async {
    try {
      final fileName = _convertTitleToFileName(recordingTitle);

      final recordingDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('recordings')
          .doc(fileName);

      await recordingDocRef.delete();

      LoggingService.instance.log(
        'Recording $fileName deleted for user $userId.',
        level: 'info',
      );
    } catch (e) {
      LoggingService.instance.log(
        'Failed to delete recording for user $userId: $e',
        level: 'error',
      );
      rethrow;
    }
  }

  // Funkcja generująca czytelne tytuły nagrań
  String _getTitle(String type, String fileName) {
    switch (type) {
      case 'individualSamples':
        return 'Próbka #${_extractNumber(fileName)}';
      case 'individualPasswords':
        return 'Hasło #${_extractNumber(fileName)}';
      case 'sharedPasswords':
        return 'Hasło współdzielone #${_extractNumber(fileName)}';
      default:
        return fileName;
    }
  }

  /// Funkcja pomocnicza do mapowania tytułów na nazwy dokumentów
  String _convertTitleToFileName(String title) {
    if (title.startsWith('Próbka')) {
      final number = title.split('#').last.trim();
      return 'IndividualSample$number';
    } else if (title.startsWith('Hasło współdzielone')) {
      final number = title.split('#').last.trim();
      return 'SharedPassword$number';
    } else if (title.startsWith('Hasło')) {
      final number = title.split('#').last.trim();
      return 'IndividualPassword$number';
    }
    throw Exception('Nieznany format tytułu: $title');
  }

  // Funkcja wyciągająca numer z nazwy pliku
  int _extractNumber(String fileName) {
    final match = RegExp(r'\d+$').firstMatch(fileName);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  // Funkcja formatująca datę na format 'dd.MM.yyyy hh:mm:ss'
  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm:ss').format(date);
  }
}
