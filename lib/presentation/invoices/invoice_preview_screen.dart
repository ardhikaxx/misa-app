import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/invoice_provider.dart';
import '../../services/pdf_generator_service.dart';

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
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final pdfService = PdfGeneratorService();
                          final pdfBytes =
                              await pdfService.generateInvoicePdf(invoice);
                          await Printing.sharePdf(
                            bytes: pdfBytes,
                            filename: '${invoice.invoiceNumber}.pdf',
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
              ),
            ],
          );
        },
      ),
    );
  }

  void _shareInvoice(dynamic invoice) async {
    final pdfService = PdfGeneratorService();
    final pdfBytes = await pdfService.generateInvoicePdf(invoice);
    await Share.shareXFiles(
      [
        XFile.fromData(
          pdfBytes,
          mimeType: 'application/pdf',
          name: '${invoice.invoiceNumber}.pdf',
        ),
      ],
      text: 'Invoice ${invoice.invoiceNumber} dari ${invoice.businessName}',
    );
  }
}
