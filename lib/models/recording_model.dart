import 'package:cloud_firestore/cloud_firestore.dart';

class RecordingModel {
  final String
      id; // Nazwa pliku nagrania bez rozszerzenia (np. IndividualSample1)
  final String
      type; // Typ nagrania: individualSample, individualPassword, sharedPassword
  final String
      filePath; // Ścieżka w Firebase Storage (np. userId/individualSamples/IndividualSample1.wav)
  final Timestamp uploadedAt; // Data przesłania nagrania
  final double duration; // Czas trwania nagrania w sekundach

  RecordingModel({
    required this.id,
    required this.type,
    required this.filePath,
    required this.uploadedAt,
    required this.duration,
  });

  /// Tworzy obiekt RecordingModel na podstawie dokumentu Firestore
  factory RecordingModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecordingModel(
      id: doc.id,
      type: data['type'] ?? '',
      filePath: data['filePath'] ?? '',
      uploadedAt: data['uploadedAt'] ?? Timestamp.now(),
      duration: (data['duration'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Konwertuje obiekt RecordingModel na mapę (do zapisania w Firestore)
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'filePath': filePath,
      'uploadedAt': uploadedAt,
      'duration': duration,
    };
  }
}
