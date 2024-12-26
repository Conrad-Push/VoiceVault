import 'package:flutter/foundation.dart';

class LoggingService {
  LoggingService._privateConstructor();
  static final LoggingService instance = LoggingService._privateConstructor();

  void log(String message, {String level = 'debug'}) {
    if (kReleaseMode && level == 'debug') {
      return;
    }
    debugPrint('[$level] $message');
  }
}
