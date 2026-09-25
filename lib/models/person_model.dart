import 'package:cloud_firestore/cloud_firestore.dart';

class PersonModel {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final String? note;
  final String? photoBase64; // Base64 image (no Storage)
  final double totalToReceive;
  final double totalToPay;
  final DateTime createdAt;
  final DateTime updatedAt;

  PersonModel({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.note,
    this.photoBase64,
    this.totalToReceive = 0,
    this.totalToPay = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  double get netBalance => totalToReceive - totalToPay;

  // true = person owes you, false = you owe person
  bool get isToReceive => netBalance >= 0;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'note': note,
      'photoBase64': photoBase64,
      'totalToReceive': totalToReceive,
      'totalToPay': totalToPay,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory PersonModel.fromMap(String id, Map<String, dynamic> map) {
    return PersonModel(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'],
      address: map['address'],
      note: map['note'],
      photoBase64: map['photoBase64'],
      totalToReceive: (map['totalToReceive'] ?? 0).toDouble(),
      totalToPay: (map['totalToPay'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  PersonModel copyWith({
    String? name,
    String? phone,
    String? address,
    String? note,
    String? photoBase64,
    double? totalToReceive,
    double? totalToPay,
  }) {
    return PersonModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      note: note ?? this.note,
      photoBase64: photoBase64 ?? this.photoBase64,
      totalToReceive: totalToReceive ?? this.totalToReceive,
      totalToPay: totalToPay ?? this.totalToPay,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
