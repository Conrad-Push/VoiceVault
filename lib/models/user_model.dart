import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String displayName;
  final String email;
  final int individualSamples;
  final int individualPasswords;
  final int sharedPasswords;
  final Timestamp createdAt;

  UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    required this.individualSamples,
    required this.individualPasswords,
    required this.sharedPasswords,
    required this.createdAt,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      individualSamples: data['recordingCounts']['individualSamples'] ?? 0,
      individualPasswords: data['recordingCounts']['individualPasswords'] ?? 0,
      sharedPasswords: data['recordingCounts']['sharedPasswords'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'recordingCounts': {
        'individualSamples': individualSamples,
        'individualPasswords': individualPasswords,
        'sharedPasswords': sharedPasswords,
      },
    };
  }
}
