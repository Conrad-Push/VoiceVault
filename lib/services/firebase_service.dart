import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  FirebaseService._privateConstructor();
  static final FirebaseService instance = FirebaseService._privateConstructor();

  Future<void> initializeFirebase(BuildContext context) async {
    try {
      await Firebase.initializeApp();
      _log('Firebase initialized successfully.', level: 'info');
    } catch (e) {
      if (context.mounted) {
        _handleError(context, e);
      }
      rethrow;
    }
  }

  Future<List<UserModel>> fetchUsers(BuildContext context) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      _log('Fetched ${snapshot.docs.length} users from Firestore.',
          level: 'info');
      return snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList();
    } catch (e) {
      if (context.mounted) {
        _handleError(context, e);
      }
      rethrow;
    }
  }

  Future<bool> isEmailRegistered(String email, BuildContext context) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      final isRegistered = snapshot.docs.isNotEmpty;
      _log('Checked if email "$email" is registered: $isRegistered',
          level: 'info');
      return isRegistered;
    } catch (e) {
      if (context.mounted) {
        _handleError(context, e);
      }
      rethrow;
    }
  }

  Future<void> addUser({
    required String name,
    required String email,
  }) async {
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
      _log('User added successfully: $name ($email)', level: 'info');
    } catch (e) {
      _log('Error adding user: $e', level: 'error');
      rethrow; // Rzucamy wyjątek, aby obsłużyć go wyżej
    }
  }

  Future<void> deleteUser(String userId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      _log('User with ID $userId deleted successfully.', level: 'info');
    } catch (e) {
      if (context.mounted) {
        _handleError(context, e);
      }
      rethrow;
    }
  }

  void _handleError(BuildContext context, Object error) {
    String userMessage = 'An unexpected error occurred.';
    String logMessage = error.toString();

    if (error is FirebaseException) {
      switch (error.code) {
        case 'unavailable':
          userMessage =
              'Unable to connect to Firestore. Please check your connection.';
          logMessage = 'Firestore unavailable: $error';
          break;
        case 'permission-denied':
          userMessage = 'Permission denied. Please check your Firestore rules.';
          logMessage = 'Firestore permission denied: $error';
          break;
        case 'not-found':
          userMessage = 'Requested resource not found.';
          logMessage = 'Firestore resource not found: $error';
          break;
        default:
          userMessage = 'A Firebase error occurred. Please try again.';
          logMessage = 'Firebase Error: $error';
      }
    } else if (error is SocketException ||
        error.toString().contains('Unable to resolve host')) {
      userMessage =
          'No Internet connection. Please check your network settings.';
      logMessage = 'SocketException: $error';
    } else {
      logMessage = 'Unexpected error: $error';
    }

    _log(logMessage, level: 'error');

    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      _showSnackBar(context, userMessage, Colors.red);
    }
  }

  void _showSnackBar(
      BuildContext context, String message, Color backgroundColor) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _log(String message, {String level = 'debug'}) {
    if (kReleaseMode && level == 'debug') {
      return;
    }
    debugPrint('[$level] $message');
  }
}
