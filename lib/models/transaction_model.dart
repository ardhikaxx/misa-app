import 'package:cloud_firestore/cloud_firestore.dart';
import 'transaction_item_model.dart';

class CustomerSnapshot {
  final String name;
  final String phoneNumber;
  final String? address;

  const CustomerSnapshot({
    required this.name,
    required this.phoneNumber,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
    };
  }

  factory CustomerSnapshot.fromMap(Map<String, dynamic> map) {
    return CustomerSnapshot(
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'],
    );
  }
}

class TransactionModel {
  final String transactionId;
  final String invoiceNumber;
  final DateTime transactionDate;
  final String customerId;
  final CustomerSnapshot customerSnapshot;
  final List<TransactionItemModel> items;
  final int subtotal;
  final int discountAmount;
  final String? discountNote;
  final int additionalFee;
  final String? additionalFeeNote;
  final int totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final int amountPaid;
  final String jobStatus;
  final String? notes;
  final DateTime? invoiceGeneratedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionModel({
    required this.transactionId,
    required this.invoiceNumber,
    required this.transactionDate,
    required this.customerId,
    required this.customerSnapshot,
    required this.items,
    required this.subtotal,
    this.discountAmount = 0,
    this.discountNote,
    this.additionalFee = 0,
    this.additionalFeeNote,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    this.amountPaid = 0,
    required this.jobStatus,
    this.notes,
    this.invoiceGeneratedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final itemsData = data['items'] as List<dynamic>? ?? [];
    return TransactionModel(
      transactionId: doc.id,
      invoiceNumber: data['invoiceNumber'] ?? '',
      transactionDate: (data['transactionDate'] as Timestamp).toDate(),
      customerId: data['customerId'] ?? '',
      customerSnapshot: CustomerSnapshot.fromMap(data['customerSnapshot'] ?? {}),
      items: itemsData.map((e) => TransactionItemModel.fromMap(e)).toList(),
      subtotal: data['subtotal'] ?? 0,
      discountAmount: data['discountAmount'] ?? 0,
      discountNote: data['discountNote'],
      additionalFee: data['additionalFee'] ?? 0,
      additionalFeeNote: data['additionalFeeNote'],
      totalAmount: data['totalAmount'] ?? 0,
      paymentMethod: data['paymentMethod'] ?? 'cash',
      paymentStatus: data['paymentStatus'] ?? 'unpaid',
      amountPaid: data['amountPaid'] ?? 0,
      jobStatus: data['jobStatus'] ?? 'waiting',
      notes: data['notes'],
      invoiceGeneratedAt: data['invoiceGeneratedAt'] != null
          ? (data['invoiceGeneratedAt'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'invoiceNumber': invoiceNumber,
      'transactionDate': Timestamp.fromDate(transactionDate),
      'customerId': customerId,
      'customerSnapshot': customerSnapshot.toMap(),
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'discountNote': discountNote,
      'additionalFee': additionalFee,
      'additionalFeeNote': additionalFeeNote,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'amountPaid': amountPaid,
      'jobStatus': jobStatus,
      'notes': notes,
      'invoiceGeneratedAt': invoiceGeneratedAt != null
          ? Timestamp.fromDate(invoiceGeneratedAt!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  TransactionModel copyWith({
    String? transactionId,
    String? invoiceNumber,
    DateTime? transactionDate,
    String? customerId,
    CustomerSnapshot? customerSnapshot,
    List<TransactionItemModel>? items,
    int? subtotal,
    int? discountAmount,
    String? discountNote,
    int? additionalFee,
    String? additionalFeeNote,
    int? totalAmount,
    String? paymentMethod,
    String? paymentStatus,
    int? amountPaid,
    String? jobStatus,
    String? notes,
    DateTime? invoiceGeneratedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      transactionId: transactionId ?? this.transactionId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      transactionDate: transactionDate ?? this.transactionDate,
      customerId: customerId ?? this.customerId,
      customerSnapshot: customerSnapshot ?? this.customerSnapshot,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      discountNote: discountNote ?? this.discountNote,
      additionalFee: additionalFee ?? this.additionalFee,
      additionalFeeNote: additionalFeeNote ?? this.additionalFeeNote,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amountPaid: amountPaid ?? this.amountPaid,
      jobStatus: jobStatus ?? this.jobStatus,
      notes: notes ?? this.notes,
      invoiceGeneratedAt: invoiceGeneratedAt ?? this.invoiceGeneratedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int calculateSubtotal(List<TransactionItemModel> items) {
    return items.fold(0, (acc, item) => acc + item.lineTotal);
  }

  static int calculateTotal({
    required int subtotal,
    required int discountAmount,
    required int additionalFee,
  }) {
    return subtotal - discountAmount + additionalFee;
  }

  static int get defaultSubtotal => 0;
  static int get defaultDiscount => 0;
  static int get defaultAdditionalFee => 0;
}
