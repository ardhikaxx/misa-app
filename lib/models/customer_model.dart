import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String customerId;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? address;
  final String? notes;
  final int totalTransactions;
  final int totalSpent;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomerModel({
    required this.customerId,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.address,
    this.notes,
    this.totalTransactions = 0,
    this.totalSpent = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomerModel(
      customerId: doc.id,
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'],
      address: data['address'],
      notes: data['notes'],
      totalTransactions: data['totalTransactions'] ?? 0,
      totalSpent: data['totalSpent'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'notes': notes,
      'totalTransactions': totalTransactions,
      'totalSpent': totalSpent,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CustomerModel copyWith({
    String? customerId,
    String? name,
    String? phoneNumber,
    String? email,
    String? address,
    String? notes,
    int? totalTransactions,
    int? totalSpent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      totalSpent: totalSpent ?? this.totalSpent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    if (words.first.length >= 2) {
      return words.first.substring(0, 2).toUpperCase();
    }
    return words.first.toUpperCase();
  }
}
