import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'logging_service.dart';

class ErrorHandlingService {
  static void handleError(BuildContext context, Object error) {
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

    // Logujemy błąd
    LoggingService.instance.log(logMessage, level: 'error');

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(userMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
