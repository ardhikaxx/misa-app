import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/invoice_model.dart';

class PdfGeneratorService {
  final NumberFormat _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  Future<Uint8List> generateInvoicePdf(InvoiceModel invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader(invoice),
          pw.SizedBox(height: 20),
          _buildInvoiceInfo(invoice),
          pw.SizedBox(height: 20),
          _buildCustomerInfo(invoice),
          pw.SizedBox(height: 20),
          _buildItemsTable(invoice),
          pw.SizedBox(height: 20),
          _buildSummary(invoice),
          pw.SizedBox(height: 30),
          _buildFooter(invoice),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(InvoiceModel invoice) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              invoice.businessName,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(invoice.businessAddress, style: const pw.TextStyle(fontSize: 10)),
            pw.Text('Telp: ${invoice.businessPhone}',
                style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'INVOICE',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              invoice.invoiceNumber,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildInvoiceInfo(InvoiceModel invoice) {
    final dateStr = DateFormat('dd MMMM yyyy', 'id_ID').format(invoice.invoiceDate);
    final statusText = invoice.paymentStatus == 'paid'
        ? 'LUNAS'
        : invoice.paymentStatus == 'partial'
            ? 'SEBAGIAN'
            : 'BELUM DIBAYAR';

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Tanggal: $dateStr', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 2),
              pw.Text('Pembayaran: ${_mapPaymentMethod(invoice.paymentMethod)}',
                  style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: invoice.paymentStatus == 'paid'
                  ? PdfColors.green100
                  : invoice.paymentStatus == 'partial'
                      ? PdfColors.orange100
                      : PdfColors.red100,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              statusText,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: invoice.paymentStatus == 'paid'
                    ? PdfColors.green800
                    : invoice.paymentStatus == 'partial'
                        ? PdfColors.orange800
                        : PdfColors.red800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCustomerInfo(InvoiceModel invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Kepada Yth:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
        pw.SizedBox(height: 4),
        pw.Text(invoice.customerName, style: const pw.TextStyle(fontSize: 12)),
        if (invoice.customerAddress != null && invoice.customerAddress!.isNotEmpty)
          pw.Text(invoice.customerAddress!, style: const pw.TextStyle(fontSize: 10)),
        pw.Text('Telp: ${invoice.customerPhone}', style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  pw.Widget _buildItemsTable(InvoiceModel invoice) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue100),
      cellAlignment: pw.Alignment.centerLeft,
      cellAlignments: {
        3: pw.Alignment.centerRight,
        4: pw.Alignment.center,
        5: pw.Alignment.centerRight,
      },
      headerAlignments: {
        3: pw.Alignment.centerRight,
        4: pw.Alignment.center,
        5: pw.Alignment.centerRight,
      },
      headerPadding: const pw.EdgeInsets.all(6),
      cellPadding: const pw.EdgeInsets.all(6),
      headers: ['No', 'Layanan', 'Harga', 'Qty', 'Diskon', 'Subtotal'],
      data: invoice.items.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final item = entry.value;
        return [
          '$index',
          item.serviceName,
          _rupiahFormat.format(item.price),
          '${item.quantity}',
          '-',
          _rupiahFormat.format(item.lineTotal),
        ];
      }).toList(),
    );
  }

  pw.Widget _buildSummary(InvoiceModel invoice) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.SizedBox(
          width: 250,
          child: pw.Column(
            children: [
              _buildSummaryRow('Subtotal', _rupiahFormat.format(invoice.subtotal)),
              if (invoice.discountAmount > 0)
                _buildSummaryRow('Diskon', '-${_rupiahFormat.format(invoice.discountAmount)}'),
              if (invoice.additionalFee > 0)
                _buildSummaryRow('Biaya Tambahan', _rupiahFormat.format(invoice.additionalFee)),
              pw.Divider(),
              _buildSummaryRow(
                'TOTAL',
                _rupiahFormat.format(invoice.totalAmount),
                isBold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
                fontSize: isBold ? 12 : 10,
              )),
          pw.Text(value,
              style: pw.TextStyle(
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
                fontSize: isBold ? 12 : 10,
              )),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(InvoiceModel invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 10),
        if (invoice.footerNote != null && invoice.footerNote!.isNotEmpty)
          pw.Text(invoice.footerNote!, style: const pw.TextStyle(fontSize: 10)),
        if (invoice.paymentStatus != 'paid' && invoice.bankAccountInfo != null) ...[
          pw.SizedBox(height: 10),
          pw.Text('Informasi Pembayaran:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.Text('Bank: ${invoice.bankAccountInfo!['bankName'] ?? '-'}', style: const pw.TextStyle(fontSize: 10)),
          pw.Text('No. Rekening: ${invoice.bankAccountInfo!['accountNumber'] ?? '-'}', style: const pw.TextStyle(fontSize: 10)),
          pw.Text('Atas Nama: ${invoice.bankAccountInfo!['accountHolder'] ?? '-'}', style: const pw.TextStyle(fontSize: 10)),
        ],
        pw.SizedBox(height: 20),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            children: [
              pw.Text('Hormat kami,', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 30),
              pw.Container(
                width: 150,
                height: 1,
                color: PdfColors.grey400,
              ),
              pw.SizedBox(height: 4),
              pw.Text(invoice.businessName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  String _mapPaymentMethod(String method) {
    switch (method) {
      case 'cash':
        return 'Tunai';
      case 'transfer':
        return 'Transfer';
      case 'qris':
        return 'QRIS';
      default:
        return method;
    }
  }
}
