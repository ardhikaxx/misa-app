import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/dashboard_provider.dart';
import '../../routing/route_paths.dart';
import '../../core/constants/app_text_styles.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.dashboard,
                        style: AppTextStyles.heading1,
                      ),
                      Text(
                        'Selamat datang!',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => context.push(RoutePaths.settings),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              dashboardAsync.when(
                loading: () => const Center(
                    child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                )),
                error: (e, st) => Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 8),
                      Text('Error: $e'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(dashboardProvider),
                        child: const Text(AppStrings.retry),
                      ),
                    ],
                  ),
                ),
                data: (data) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: AppStrings.todayIncome,
                            value: CurrencyFormatter.format(data.todayIncome),
                            icon: Icons.today,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            title: AppStrings.monthlyIncome,
                            value: CurrencyFormatter.format(data.monthlyIncome),
                            icon: Icons.calendar_month,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SummaryCard(
                      title: AppStrings.pendingJobs,
                      value: '${data.pendingJobs} pekerjaan',
                      icon: Icons.pending_actions,
                      color: AppColors.warning,
                      isFullWidth: true,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          AppStrings.recentTransactions,
                          style: AppTextStyles.heading3,
                        ),
                        TextButton(
                          onPressed: () => context.push(RoutePaths.transactions),
                          child: const Text(AppStrings.viewAll),
                        ),
                      ],
                    ),
                    if (data.recentTransactions.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'Belum ada transaksi hari ini',
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        ),
                      )
                    else
                      ...data.recentTransactions.map(
                        (t) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: t.paymentStatus == 'paid'
                                  ? AppColors.paid
                                  : AppColors.unpaid,
                              child: Text(
                                t.customerSnapshot.name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(t.customerSnapshot.name),
                            subtitle: Text(t.invoiceNumber),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyFormatter.format(t.totalAmount),
                                  style: AppTextStyles.price,
                                ),
                                Text(
                                  t.paymentStatus == 'paid'
                                      ? AppStrings.paid
                                      : t.paymentStatus == 'partial'
                                          ? AppStrings.partial
                                          : AppStrings.unpaid,
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isFullWidth;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
