import 'package:cloud_firestore/cloud_firestore.dart';

class RateModel {
  final String id;
  final String type; // 'kapas', 'paani', 'mazdoori'
  final double ratePerUnit;
  final DateTime effectiveFrom;
  final DateTime createdAt;

  RateModel({
    required this.id,
    required this.type,
    required this.ratePerUnit,
    required this.effectiveFrom,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'ratePerUnit': ratePerUnit,
      'effectiveFrom': Timestamp.fromDate(effectiveFrom),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RateModel.fromMap(String id, Map<String, dynamic> map) {
    return RateModel(
      id: id,
      type: map['type'] ?? 'kapas',
      ratePerUnit: (map['ratePerUnit'] ?? 0).toDouble(),
      effectiveFrom:
          (map['effectiveFrom'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
