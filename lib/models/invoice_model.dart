class InvoiceModel {
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String businessName;
  final String businessAddress;
  final String businessPhone;
  final String? businessLogo;
  final String customerName;
  final String customerPhone;
  final String? customerAddress;
  final List<InvoiceItem> items;
  final int subtotal;
  final int discountAmount;
  final int additionalFee;
  final int totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String? footerNote;
  final Map<String, String>? bankAccountInfo;

  const InvoiceModel({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.businessName,
    required this.businessAddress,
    required this.businessPhone,
    this.businessLogo,
    required this.customerName,
    required this.customerPhone,
    this.customerAddress,
    required this.items,
    required this.subtotal,
    this.discountAmount = 0,
    this.additionalFee = 0,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    this.footerNote,
    this.bankAccountInfo,
  });

  factory InvoiceModel.fromTransaction({
    required String invoiceNumber,
    required DateTime transactionDate,
    required String businessName,
    required String businessAddress,
    required String businessPhone,
    String? businessLogo,
    required String customerName,
    required String customerPhone,
    String? customerAddress,
    required List<InvoiceItem> items,
    required int subtotal,
    int discountAmount = 0,
    int additionalFee = 0,
    required int totalAmount,
    required String paymentMethod,
    required String paymentStatus,
    String? footerNote,
    Map<String, String>? bankAccountInfo,
  }) {
    return InvoiceModel(
      invoiceNumber: invoiceNumber,
      invoiceDate: transactionDate,
      businessName: businessName,
      businessAddress: businessAddress,
      businessPhone: businessPhone,
      businessLogo: businessLogo,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      items: items,
      subtotal: subtotal,
      discountAmount: discountAmount,
      additionalFee: additionalFee,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      footerNote: footerNote,
      bankAccountInfo: bankAccountInfo,
    );
  }
}

class InvoiceItem {
  final String serviceName;
  final int price;
  final int quantity;
  final int lineTotal;

  const InvoiceItem({
    required this.serviceName,
    required this.price,
    required this.quantity,
    required this.lineTotal,
  });
}
