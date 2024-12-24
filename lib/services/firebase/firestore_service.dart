import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import 'logging_service.dart';

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

      // Pobieranie podkolekcji 'recordings'
      final recordingsRef = userRef.collection('recordings');
      final recordingsSnapshot = await recordingsRef.get();

      // Usuwanie podkolekcji 'recordings'
      for (final doc in recordingsSnapshot.docs) {
        final subcollectionRef = recordingsRef.doc(doc.id).collection(doc.id);
        final subcollectionSnapshot = await subcollectionRef.get();

        for (final subDoc in subcollectionSnapshot.docs) {
          await subDoc.reference.delete();
        }

        // Usuwamy sam dokument podkolekcji (np. 'individualSamples', 'sharedPasswords')
        await doc.reference.delete();
      }

      // Na końcu usuwamy dokument główny użytkownika
      await userRef.delete();

      LoggingService.instance.log(
          'User with ID $userId and all related recordings deleted successfully.',
          level: 'info');
    } catch (e) {
      LoggingService.instance.log(
          'Failed to delete user $userId and related recordings: $e',
          level: 'error');
      rethrow;
    }
  }

  Future<void> addRecording({
    required String userId,
    required String type,
    required String filePath,
    required Timestamp uploadedAt,
    required double duration,
    required String fileName,
  }) async {
    try {
      final recordingDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('recordings')
          .doc(type)
          .collection(type)
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
      LoggingService.instance.log(
          'Failed to add recording $fileName for user $userId: $e',
          level: 'error');
      rethrow;
    }
  }
}
