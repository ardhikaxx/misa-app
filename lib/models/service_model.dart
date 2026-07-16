import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String serviceId;
  final String serviceName;
  final String category;
  final int price;
  final String estimatedDuration;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceModel({
    required this.serviceId,
    required this.serviceName,
    required this.category,
    required this.price,
    required this.estimatedDuration,
    this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      serviceId: doc.id,
      serviceName: data['serviceName'] ?? '',
      category: data['category'] ?? '',
      price: data['price'] ?? 0,
      estimatedDuration: data['estimatedDuration'] ?? '',
      description: data['description'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'category': category,
      'price': price,
      'estimatedDuration': estimatedDuration,
      'description': description,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ServiceModel copyWith({
    String? serviceId,
    String? serviceName,
    String? category,
    int? price,
    String? estimatedDuration,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      category: category ?? this.category,
      price: price ?? this.price,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
