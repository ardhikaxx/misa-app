import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/transaction_provider.dart';
import '../../routing/route_paths.dart';
import '../../core/constants/app_text_styles.dart';

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
                        const Text(AppStrings.jobStatus,
                            style: AppTextStyles.heading3),
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
