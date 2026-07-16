import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/invoice_provider.dart';
import '../../services/pdf_generator_service.dart';
import '../../models/invoice_model.dart';

class InvoicePreviewScreen extends ConsumerWidget {
  final String transactionId;

  const InvoicePreviewScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceAsync = ref.watch(invoicePreviewProvider(transactionId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.previewInvoice),
        actions: [
          invoiceAsync.when(
            loading: () => const SizedBox(),
            error: (e, st) => const SizedBox(),
            data: (invoice) {
              if (invoice == null) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareInvoice(invoice),
              );
            },
          ),
        ],
      ),
      body: invoiceAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Membuat invoice...'),
            ],
          ),
        ),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Gagal membuat invoice: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(
                    invoicePreviewProvider(transactionId)),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
        data: (invoice) {
          if (invoice == null) {
            return const Center(
              child: Text('Invoice tidak ditemukan'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: PdfPreview(
                  build: (format) async {
                    final pdfService = PdfGeneratorService();
                    return await pdfService.generateInvoicePdf(invoice);
                  },
                  allowSharing: false,
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                         Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final pdfService = PdfGeneratorService();
                              final pdfBytes =
                                  await pdfService.generateInvoicePdf(invoice);
                              final tempDir = Directory.systemTemp;
                              final safeName = invoice.invoiceNumber.replaceAll('/', '_');
                              final file = File('${tempDir.path}/$safeName.pdf');
                              await file.create(recursive: true);
                              await file.writeAsBytes(pdfBytes);
                              await Share.shareXFiles(
                                [XFile(file.path)],
                                text: 'Invoice ${invoice.invoiceNumber} dari ${invoice.businessName}',
                              );
                            },
                            icon: const Icon(Icons.print),
                            label: const Text(AppStrings.printInvoice),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _shareInvoice(invoice),
                            icon: const Icon(Icons.share),
                            label: const Text(AppStrings.shareInvoice),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _shareWhatsApp(invoice),
                        icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                        label: const Text('Bagikan via WhatsApp',
                            style: TextStyle(color: Color(0xFF25D366))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF25D366)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _shareInvoice(InvoiceModel invoice) async {
    final pdfService = PdfGeneratorService();
    final pdfBytes = await pdfService.generateInvoicePdf(invoice);
    final tempDir = Directory.systemTemp;
    final safeName = invoice.invoiceNumber.replaceAll('/', '_');
    final file = File('${tempDir.path}/$safeName.pdf');
    await file.create(recursive: true);
    await file.writeAsBytes(pdfBytes);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Invoice ${invoice.invoiceNumber} dari ${invoice.businessName}',
    );
  }

  void _shareWhatsApp(InvoiceModel invoice) async {
    final items = invoice.items
        .map((item) => '- ${item.serviceName} x${item.quantity}: Rp ${item.lineTotal}')
        .join('\n');
    final text = Uri.encodeComponent(
      'Halo ${invoice.customerName} 👋\n\n'
      'Berikut invoice dari *${invoice.businessName}*:\n\n'
      'No: ${invoice.invoiceNumber}\n'
      'Tanggal: ${invoice.invoiceDate.day}/${invoice.invoiceDate.month}/${invoice.invoiceDate.year}\n\n'
      '$items\n\n'
      'Subtotal: Rp ${invoice.subtotal}\n'
      '${invoice.discountAmount > 0 ? 'Diskon: -Rp ${invoice.discountAmount}\n' : ''}'
      '${invoice.additionalFee > 0 ? 'Biaya Tambahan: Rp ${invoice.additionalFee}\n' : ''}'
      '*Total: Rp ${invoice.totalAmount}*\n\n'
      'Terima kasih 🙏',
    );
    await Share.share('https://wa.me/?text=$text');
  }
}
