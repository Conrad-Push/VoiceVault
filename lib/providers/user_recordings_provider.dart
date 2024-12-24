import 'package:flutter/material.dart';

class UserRecordingsProvider with ChangeNotifier {
  String? _userId;
  String? _userName;

  /// Getter dla userId
  String? get userId => _userId;

  /// Getter dla userName
  String? get userName => _userName;

  /// Ustawia aktualnego użytkownika
  void setUser({required String userId, required String userName}) {
    _userId = userId;
    _userName = userName;
    debugPrint(
        'UserRecordingsProvider: Set userId = $_userId, userName = $_userName');
    notifyListeners();
  }

  /// Czyści dane aktualnego użytkownika
  void clearData() {
    debugPrint(
        'UserRecordingsProvider: Clearing data. Previous userId = $_userId, userName = $_userName');
    _userId = null;
    _userName = null;
    notifyListeners();
    debugPrint(
        'UserRecordingsProvider: Data cleared. userId = $_userId, userName = $_userName');
  }
}
