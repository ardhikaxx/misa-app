import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/customer_provider.dart';
import '../../routing/route_paths.dart';
import '../../core/constants/app_text_styles.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customerListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Pelanggan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final customers = ref.read(customerListProvider).valueOrNull;
              if (customers == null || customers.isEmpty) return;

              try {
                final customer = customers.firstWhere(
                  (c) => c.customerId == customerId,
                );
                ref.read(customerFormProvider.notifier).loadCustomer(customer);
                context.push(
                  '${RoutePaths.customerForm}?customerId=$customerId',
                );
              } catch (_) {}
            },
          ),
        ],
      ),
      body: customersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (customers) {
          if (customers.isEmpty) {
            return const Center(child: Text('Pelanggan tidak ditemukan'));
          }

          try {
            final customer = customers.firstWhere(
              (c) => c.customerId == customerId,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              customer.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            customer.name,
                            style: AppTextStyles.heading2,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            customer.phoneNumber,
                            style: AppTextStyles.body,
                          ),
                          if (customer.email != null && customer.email!.isNotEmpty)
                            Text(
                              customer.email!,
                              style: AppTextStyles.bodySmall,
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
                          const Text('Statistik', style: AppTextStyles.heading3),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _StatItem(
                                  label: 'Total Transaksi',
                                  value: '${customer.totalTransactions}',
                                  icon: Icons.receipt,
                                ),
                              ),
                              Expanded(
                                child: _StatItem(
                                  label: 'Total Belanja',
                                  value: CurrencyFormatter.format(customer.totalSpent),
                                  icon: Icons.account_balance_wallet,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (customer.address != null && customer.address!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.location_on),
                        title: const Text('Alamat'),
                        subtitle: Text(customer.address!),
                      ),
                    ),
                  ],
                  if (customer.notes != null && customer.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.notes),
                        title: const Text('Catatan'),
                        subtitle: Text(customer.notes!),
                      ),
                    ),
                  ],
                ],
              ),
            );
          } catch (_) {
            return const Center(child: Text('Pelanggan tidak ditemukan'));
          }
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
