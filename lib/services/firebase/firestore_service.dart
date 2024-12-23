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
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      LoggingService.instance
          .log('User with ID $userId deleted successfully.', level: 'info');
    } catch (e) {
      LoggingService.instance.log('Failed to delete user: $e', level: 'error');
      rethrow;
    }
  }
}
