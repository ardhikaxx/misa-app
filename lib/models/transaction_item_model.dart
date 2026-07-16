class TransactionItemModel {
  final String serviceId;
  final String serviceName;
  final int price;
  final int quantity;
  final int lineTotal;

  const TransactionItemModel({
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.quantity,
    required this.lineTotal,
  });

  factory TransactionItemModel.fromMap(Map<String, dynamic> map) {
    return TransactionItemModel(
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      price: map['price'] ?? 0,
      quantity: map['quantity'] ?? 1,
      lineTotal: map['lineTotal'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'price': price,
      'quantity': quantity,
      'lineTotal': lineTotal,
    };
  }

  TransactionItemModel copyWith({
    String? serviceId,
    String? serviceName,
    int? price,
    int? quantity,
    int? lineTotal,
  }) {
    return TransactionItemModel(
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      lineTotal: lineTotal ?? this.lineTotal,
    );
  }

  static TransactionItemModel calculate({
    required String serviceId,
    required String serviceName,
    required int price,
    required int quantity,
  }) {
    return TransactionItemModel(
      serviceId: serviceId,
      serviceName: serviceName,
      price: price,
      quantity: quantity,
      lineTotal: price * quantity,
    );
  }
}
