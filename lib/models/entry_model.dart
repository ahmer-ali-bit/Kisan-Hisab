import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart'; // Import EntryTypes from constants.dart

class EntryModel {
  final String id;
  final String
      type; // kapas, paani, mazdoori, expense, payment_receive, payment_pay
  final String? personId; // Optional for general expenses
  final String? personName; // Cached for quick display
  final DateTime date;
  final double amount;
  final String? note;
  final Map<String, dynamic> typeData; // Type-specific data
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  EntryModel({
    required this.id,
    required this.type,
    this.personId,
    this.personName,
    required this.date,
    required this.amount,
    this.note,
    this.typeData = const {},
    this.isDeleted = false,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'personId': personId,
      'personName': personName,
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'note': note,
      'typeData': typeData,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory EntryModel.fromMap(String id, Map<String, dynamic> map) {
    return EntryModel(
      id: id,
      type: map['type'] ?? '',
      personId: map['personId'],
      personName: map['personName'],
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      amount: (map['amount'] ?? 0).toDouble(),
      note: map['note'],
      typeData: Map<String, dynamic>.from(map['typeData'] ?? {}),
      isDeleted: map['isDeleted'] ?? false,
      deletedAt: (map['deletedAt'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  EntryModel copyWith({
    String? type,
    String? personId,
    String? personName,
    DateTime? date,
    double? amount,
    String? note,
    Map<String, dynamic>? typeData,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return EntryModel(
      id: id,
      type: type ?? this.type,
      personId: personId ?? this.personId,
      personName: personName ?? this.personName,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      typeData: typeData ?? this.typeData,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Helper: Is this entry a "to receive" for you?
  bool get isToReceive {
    return type == EntryTypes.kapas ||
        type == EntryTypes.paani ||
        type == EntryTypes.paymentPay;
  }

  bool get isToPay {
    return type == EntryTypes.mazdoori ||
        type == EntryTypes.expense ||
        type == EntryTypes.paymentReceive;
  }
}
