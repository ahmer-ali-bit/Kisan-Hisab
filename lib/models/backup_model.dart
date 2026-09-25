import 'package:cloud_firestore/cloud_firestore.dart';

class BackupModel {
  final String id;
  final String label;
  final DateTime createdAt;
  final int peopleCount;
  final int entriesCount;
  final int ratesCount;
  final int sizeBytes; // approx Base64 string length

  BackupModel({
    required this.id,
    required this.label,
    required this.createdAt,
    required this.peopleCount,
    required this.entriesCount,
    required this.ratesCount,
    required this.sizeBytes,
  });

  factory BackupModel.fromMap(String id, Map<String, dynamic> map) {
    return BackupModel(
      id: id,
      label: map['label'] ?? 'Backup',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      peopleCount: map['peopleCount'] ?? 0,
      entriesCount: map['entriesCount'] ?? 0,
      ratesCount: map['ratesCount'] ?? 0,
      sizeBytes: map['sizeBytes'] ?? 0,
    );
  }

  String get sizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
