import 'package:cloud_firestore/cloud_firestore.dart';

enum BusinessCategory {
  servisAC('Servis AC'),
  salon('Salon'),
  laundry('Laundry'),
  fotografi('Fotografi'),
  desainGrafis('Desain Grafis'),
  percetakan('Percetakan'),
  servisElektronik('Servis Elektronik'),
  bengkel('Bengkel'),
  catering('Catering'),
  jasaDigital('Jasa Digital'),
  lainnya('Lainnya');

  final String label;
  const BusinessCategory(this.label);
}

class BusinessModel {
  final String businessId;
  final String ownerName;
  final String businessName;
  final String businessCategory;
  final String address;
  final String whatsappNumber;
  final String email;
  final String? logoUrl;
  final Map<String, String>? bankAccountInfo;
  final String? qrisImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSetupComplete;

  const BusinessModel({
    required this.businessId,
    required this.ownerName,
    required this.businessName,
    required this.businessCategory,
    required this.address,
    required this.whatsappNumber,
    required this.email,
    this.logoUrl,
    this.bankAccountInfo,
    this.qrisImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isSetupComplete = false,
  });

  factory BusinessModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BusinessModel(
      businessId: doc.id,
      ownerName: data['ownerName'] ?? '',
      businessName: data['businessName'] ?? '',
      businessCategory: data['businessCategory'] ?? '',
      address: data['address'] ?? '',
      whatsappNumber: data['whatsappNumber'] ?? '',
      email: data['email'] ?? '',
      logoUrl: data['logoUrl'],
      bankAccountInfo: data['bankAccountInfo'] != null
          ? Map<String, String>.from(data['bankAccountInfo'])
          : null,
      qrisImageUrl: data['qrisImageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isSetupComplete: data['isSetupComplete'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessId': businessId,
      'ownerName': ownerName,
      'businessName': businessName,
      'businessCategory': businessCategory,
      'address': address,
      'whatsappNumber': whatsappNumber,
      'email': email,
      'logoUrl': logoUrl,
      'bankAccountInfo': bankAccountInfo,
      'qrisImageUrl': qrisImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isSetupComplete': isSetupComplete,
    };
  }

  BusinessModel copyWith({
    String? businessId,
    String? ownerName,
    String? businessName,
    String? businessCategory,
    String? address,
    String? whatsappNumber,
    String? email,
    String? logoUrl,
    Map<String, String>? bankAccountInfo,
    String? qrisImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSetupComplete,
  }) {
    return BusinessModel(
      businessId: businessId ?? this.businessId,
      ownerName: ownerName ?? this.ownerName,
      businessName: businessName ?? this.businessName,
      businessCategory: businessCategory ?? this.businessCategory,
      address: address ?? this.address,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      email: email ?? this.email,
      logoUrl: logoUrl ?? this.logoUrl,
      bankAccountInfo: bankAccountInfo ?? this.bankAccountInfo,
      qrisImageUrl: qrisImageUrl ?? this.qrisImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
    );
  }

  String get initials {
    final words = businessName.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    if (words.first.length >= 2) {
      return words.first.substring(0, 2).toUpperCase();
    }
    return words.first.toUpperCase();
  }
}
