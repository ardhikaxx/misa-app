import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/customer_provider.dart';
import '../../routing/route_paths.dart';
import '../../core/constants/app_text_styles.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customerListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.customers),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(RoutePaths.customerForm),
          ),
        ],
      ),
      body: customersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (customers) {
          if (customers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada pelanggan',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tambahkan data pelanggan Anda',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push(RoutePaths.customerForm),
                    icon: const Icon(Icons.add),
                    label: const Text(AppStrings.addCustomer),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      customer.initials,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(customer.name),
                  subtitle: Text(
                    customer.phoneNumber,
                    style: AppTextStyles.bodySmall,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${customer.totalTransactions} transaksi',
                        style: AppTextStyles.caption,
                      ),
                      Text(
                        CurrencyFormatter.formatShort(customer.totalSpent),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => context.push(
                    '${RoutePaths.customerDetail.replaceAll(':id', '')}${customer.customerId}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
