import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/transaction_provider.dart';
import '../../routing/route_paths.dart';
import '../../core/constants/app_text_styles.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.transactions),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(RoutePaths.transactionForm),
          ),
        ],
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada transaksi',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Buat transaksi pertama Anda',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push(RoutePaths.transactionForm),
                    icon: const Icon(Icons.add),
                    label: const Text(AppStrings.addTransaction),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final t = transactions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getJobStatusColor(t.jobStatus),
                    child: Text(
                      t.jobStatus.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    t.customerSnapshot.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${t.invoiceNumber} - ${DateFormatter.short(t.transactionDate)}',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          _StatusChip(
                            label: _mapPaymentStatus(t.paymentStatus),
                            color: _getPaymentStatusColor(t.paymentStatus),
                          ),
                          const SizedBox(width: 6),
                          _StatusChip(
                            label: _mapJobStatus(t.jobStatus),
                            color: _getJobStatusColor(t.jobStatus),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Text(
                    CurrencyFormatter.format(t.totalAmount),
                    style: AppTextStyles.price,
                  ),
                  isThreeLine: true,
                  onTap: () => context.push(
                    '${RoutePaths.transactionDetail.replaceAll(':id', '')}${t.transactionId}',
                  ),
                ),
              );
            },
          );
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

  Color _getJobStatusColor(String status) {
    switch (status) {
      case 'in_progress':
        return AppColors.inProgress;
      case 'done':
        return AppColors.done;
      case 'delivered':
        return AppColors.delivered;
      default:
        return AppColors.waiting;
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

  String _mapJobStatus(String status) {
    switch (status) {
      case 'in_progress':
        return AppStrings.inProgress;
      case 'done':
        return AppStrings.done;
      case 'delivered':
        return AppStrings.delivered;
      default:
        return AppStrings.waiting;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
