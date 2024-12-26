import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../logging_service.dart';

class FirebaseCoreService {
  FirebaseCoreService._privateConstructor();
  static final FirebaseCoreService instance =
      FirebaseCoreService._privateConstructor();

  Future<void> initializeFirebase(BuildContext context) async {
    try {
      await Firebase.initializeApp();
      LoggingService.instance
          .log('Firebase initialized successfully.', level: 'info');
    } catch (e) {
      LoggingService.instance
          .log('Firebase initialization failed: $e', level: 'error');
      rethrow;
    }
  }
}
