import '../models/invoice_model.dart';
import 'transaction_service.dart';
import 'business_service.dart';

class InvoiceService {
  final TransactionService _transactionService = TransactionService();
  final BusinessService _businessService = BusinessService();

  Future<InvoiceModel?> generateInvoice({
    required String uid,
    required String transactionId,
  }) async {
    final transaction = await _transactionService.getTransaction(uid, transactionId);
    if (transaction == null) return null;

    final business = await _businessService.getBusiness(uid);
    if (business == null) return null;

    final items = transaction.items
        .map((item) => InvoiceItem(
              serviceName: item.serviceName,
              price: item.price,
              quantity: item.quantity,
              lineTotal: item.lineTotal,
            ))
        .toList();

    final invoice = InvoiceModel.fromTransaction(
      invoiceNumber: transaction.invoiceNumber,
      transactionDate: transaction.transactionDate,
      businessName: business.businessName,
      businessAddress: business.address,
      businessPhone: business.whatsappNumber,
      businessLogo: business.logoUrl,
      customerName: transaction.customerSnapshot.name,
      customerPhone: transaction.customerSnapshot.phoneNumber,
      customerAddress: transaction.customerSnapshot.address,
      items: items,
      subtotal: transaction.subtotal,
      discountAmount: transaction.discountAmount,
      additionalFee: transaction.additionalFee,
      totalAmount: transaction.totalAmount,
      paymentMethod: transaction.paymentMethod,
      paymentStatus: transaction.paymentStatus,
      footerNote: 'Terima kasih telah menggunakan jasa kami',
      bankAccountInfo: business.bankAccountInfo,
    );

    await _transactionService.markInvoiceGenerated(uid, transactionId);

    return invoice;
  }
}
