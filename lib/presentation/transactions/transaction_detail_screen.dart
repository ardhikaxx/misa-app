import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';
import '../../routing/route_paths.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/app_toast.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.transactionDetail),
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text('Transaksi tidak ditemukan'));
          }

          try {
            final transaction = transactions.firstWhere(
              (t) => t.transactionId == transactionId,
            );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              transaction.invoiceNumber,
                              style: AppTextStyles.heading3,
                            ),
                            _StatusBadge(
                              label: _mapPaymentStatus(transaction.paymentStatus),
                              color: _getPaymentStatusColor(transaction.paymentStatus),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${transaction.transactionDate.day}/${transaction.transactionDate.month}/${transaction.transactionDate.year}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        transaction.customerSnapshot.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(transaction.customerSnapshot.name),
                    subtitle: Text(transaction.customerSnapshot.phoneNumber),
                  ),
                ),
                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(AppStrings.jobStatus,
                                style: AppTextStyles.heading3),
                            _buildJobStatusDropdown(
                                context, ref, transaction.jobStatus, transactionId),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _JobStatusStepper(currentStatus: transaction.jobStatus),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Rincian Layanan',
                            style: AppTextStyles.heading3),
                        const SizedBox(height: 12),
                        ...transaction.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.serviceName),
                                      Text(
                                        '${item.quantity} x ${CurrencyFormatter.format(item.price)}',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(item.lineTotal),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        _SummaryRow(
                            label: AppStrings.subtotal,
                            value: CurrencyFormatter.format(
                                transaction.subtotal)),
                        if (transaction.discountAmount > 0)
                          _SummaryRow(
                            label: 'Diskon',
                            value:
                                '-${CurrencyFormatter.format(transaction.discountAmount)}',
                          ),
                        if (transaction.additionalFee > 0)
                          _SummaryRow(
                            label: 'Biaya Tambahan',
                            value: CurrencyFormatter.format(
                                transaction.additionalFee),
                          ),
                        const Divider(),
                        _SummaryRow(
                          label: AppStrings.totalAmount,
                          value: CurrencyFormatter.format(
                              transaction.totalAmount),
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Info Pembayaran',
                            style: AppTextStyles.heading3),
                        const SizedBox(height: 8),
                        _InfoRow(
                            label: 'Metode',
                            value: _mapPaymentMethod(transaction.paymentMethod)),
                        _InfoRow(
                            label: 'Status',
                            value: _mapPaymentStatus(transaction.paymentStatus)),
                        _InfoRow(
                            label: 'Dibayar',
                            value: CurrencyFormatter.format(
                                transaction.amountPaid)),
                      ],
                    ),
                  ),
                ),

                if (transaction.notes != null && transaction.notes!.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.only(top: 12),
                    child: ListTile(
                      leading: const Icon(Icons.notes),
                      title: const Text('Catatan'),
                      subtitle: Text(transaction.notes!),
                    ),
                  ),

                const SizedBox(height: 24),

                if (transaction.invoiceGeneratedAt == null)
                  ElevatedButton.icon(
                    onPressed: () => context.push(
                      RoutePaths.invoicePreview.replaceAll(':id', transactionId),
                    ),
                    icon: const Icon(Icons.receipt),
                    label: const Text(AppStrings.createInvoice),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => context.push(
                      RoutePaths.invoicePreview.replaceAll(':id', transactionId),
                    ),
                    icon: const Icon(Icons.receipt),
                    label: const Text(AppStrings.previewInvoice),
                  ),

                // ── Reminder WhatsApp (hanya untuk unpaid/partial) ──
                if (transaction.paymentStatus != 'paid') ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _sendWhatsAppReminder(context, ref, transaction),
                    icon: const Icon(Icons.whatsapp, color: Color(0xFF25D366)),
                    label: const Text(
                      'Kirim Reminder Pembayaran',
                      style: TextStyle(color: Color(0xFF25D366)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF25D366)),
                    ),
                  ),
                ],

                // ── Duplikasi Transaksi ──
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      _duplicateTransaction(context, ref, transaction),
                  icon: const Icon(Icons.copy_all),
                  label: const Text('Duplikasi Transaksi'),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
          } catch (_) {
            return const Center(child: Text('Transaksi tidak ditemukan'));
          }
        },
      ),
    );
  }

  /// Buka WhatsApp dengan pesan reminder pembayaran siap kirim
  Future<void> _sendWhatsAppReminder(
    BuildContext context,
    WidgetRef ref,
    dynamic transaction,
  ) async {
    final business = ref.read(businessProfileSyncProvider);
    final remaining = transaction.totalAmount - transaction.amountPaid;
    final phone = transaction.customerSnapshot.phoneNumber
        .replaceAll(RegExp(r'[^\d]'), '')
        .replaceFirst(RegExp(r'^0'), '62');

    final businessName = business?.businessName ?? 'Kami';
    final bank = business?.bankAccountInfo;
    final bankInfo = (bank != null &&
            bank['accountNumber'] != null &&
            bank['accountNumber']!.isNotEmpty)
        ? '\n\nInfo Pembayaran:\n'
            '${bank['bankName'] ?? ''} - ${bank['accountNumber'] ?? ''}\n'
            'a.n. ${bank['accountHolder'] ?? ''}'
        : '';

    final message = 'Halo ${transaction.customerSnapshot.name},\n\n'
        'Kami dari *$businessName* ingin mengingatkan bahwa tagihan Anda '
        'belum lunas.\n\n'
        'No. Invoice: *${transaction.invoiceNumber}*\n'
        'Total Tagihan: *${CurrencyFormatter.format(transaction.totalAmount)}*\n'
        '${transaction.paymentStatus == 'partial' ? 'Sudah Dibayar: *${CurrencyFormatter.format(transaction.amountPaid)}*\n' : ''}'
        'Sisa Tagihan: *${CurrencyFormatter.format(remaining)}*'
        '$bankInfo\n\n'
        'Terima kasih 🙏';

    final url = Uri.parse(
        'https://wa.me/$phone?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      AppToast.error(context, 'Tidak bisa membuka WhatsApp');
    }
  }

  /// Duplikasi transaksi — buat transaksi baru dengan data yang sama
  Future<void> _duplicateTransaction(
    BuildContext context,
    WidgetRef ref,
    dynamic transaction,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Duplikasi Transaksi'),
        content: Text(
          'Buat transaksi baru berdasarkan\n'
          '${transaction.invoiceNumber} - ${transaction.customerSnapshot.name}?\n\n'
          'Status akan direset ke: Belum Bayar & Menunggu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Duplikasi'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    final business = ref.read(businessProfileSyncProvider);
    final service = ref.read(transactionServiceProvider);

    try {
      final invoiceNumber = await service.generateInvoiceNumber(
          uid, business?.businessName ?? 'MISA');
      final newId =
          await service.duplicateTransaction(uid, transaction, invoiceNumber);

      if (context.mounted) {
        AppToast.success(context, 'Transaksi berhasil diduplikasi');
        context.push(
          '${RoutePaths.transactionDetail.replaceAll(':id', '')}$newId',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, 'Gagal menduplikasi: $e');
      }
    }
  }

  Widget _buildJobStatusDropdown(BuildContext context, WidgetRef ref,
      String currentStatus, String transactionId) {
    final statuses = <String, String>{
      'waiting': AppStrings.waiting,
      'in_progress': AppStrings.inProgress,
      'done': AppStrings.done,
      'delivered': AppStrings.delivered,
    };

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Ubah Status Pekerjaan',
                      style: AppTextStyles.heading3),
                ),
                ...statuses.entries.map(
                  (e) => ListTile(
                    leading: Icon(
                      e.key == currentStatus
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: e.key == currentStatus
                          ? AppColors.primary
                          : AppColors.textHint,
                    ),
                    title: Text(e.value),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final uid = ref.read(currentUserIdProvider);
                      if (uid == null) return;
                      await ref
                          .read(transactionServiceProvider)
                          .updateJobStatus(uid, transactionId, e.key);
                      if (context.mounted) {
                        AppToast.success(context, 'Status: ${e.value}');
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
      child: Chip(
        label: Text(
          statuses[currentStatus] ?? currentStatus,
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        avatar: const Icon(Icons.edit, size: 16, color: Colors.white),
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'paid':
        return AppColors.paid;
      case 'partial':
        return AppColors.partial;
      default:
        return AppColors.unpaid;
    }
  }

  String _mapPaymentStatus(String status) {
    switch (status) {
      case 'paid':
        return AppStrings.paid;
      case 'partial':
        return AppStrings.partial;
      default:
        return AppStrings.unpaid;
    }
  }

  String _mapPaymentMethod(String method) {
    switch (method) {
      case 'cash':
        return AppStrings.cash;
      case 'transfer':
        return AppStrings.transfer;
      case 'qris':
        return AppStrings.qris;
      default:
        return method;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _JobStatusStepper extends StatelessWidget {
  final String currentStatus;

  const _JobStatusStepper({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final statuses = [
      ('waiting', AppStrings.waiting, AppColors.waiting),
      ('in_progress', AppStrings.inProgress, AppColors.inProgress),
      ('done', AppStrings.done, AppColors.done),
      ('delivered', AppStrings.delivered, AppColors.delivered),
    ];

    final currentIndex = statuses.indexWhere((s) => s.$1 == currentStatus);

    return Row(
      children: List.generate(statuses.length, (index) {
        final isActive = index <= currentIndex;
        final isCurrent = index == currentIndex;
        final (_, label, color) = statuses[index];

        return Expanded(
          child: Column(
            children: [
              Container(
                width: isCurrent ? 32 : 24,
                height: isCurrent ? 32 : 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? color : AppColors.divider,
                ),
                child: isActive
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? color : AppColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              )),
          Text(value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold ? AppColors.primary : null,
              )),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
