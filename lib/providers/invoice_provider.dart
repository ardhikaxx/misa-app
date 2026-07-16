import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/invoice_service.dart';
import '../services/pdf_generator_service.dart';
import '../models/invoice_model.dart';
import 'auth_provider.dart';

final invoiceServiceProvider = Provider<InvoiceService>(
    (ref) => InvoiceService());

final pdfGeneratorServiceProvider = Provider<PdfGeneratorService>(
    (ref) => PdfGeneratorService());

final invoicePreviewProvider =
    FutureProvider.family<InvoiceModel?, String>((ref, transactionId) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return null;

  final service = ref.watch(invoiceServiceProvider);
  return service.generateInvoice(uid: uid, transactionId: transactionId);
});
