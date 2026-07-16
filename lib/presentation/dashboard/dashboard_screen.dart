import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/service_catalog_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../routing/route_paths.dart';
import '../../core/constants/app_text_styles.dart';

final _dashboardTabProvider = StateProvider<int>((ref) => 0);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(_dashboardTabProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,
          children: const [
            _HomeTab(),
            _ServicesTab(),
            _CustomersTab(),
            _TransactionsTab(),
            _MoreTab(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => ref.read(_dashboardTabProvider.notifier).state = index,
        backgroundColor: Colors.white,
        elevation: 8,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work, color: AppColors.primary),
            label: 'Layanan',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: AppColors.primary),
            label: 'Pelanggan',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: AppColors.primary),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu),
            selectedIcon: Icon(Icons.menu, color: AppColors.primary),
            label: 'Lainnya',
          ),
        ],
      ),
    );
  }
}

// ─── HOME TAB ──────────────────────────────────────────────
class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(dashboardProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.dashboard, style: AppTextStyles.heading1),
                  Text('Selamat datang!', style: AppTextStyles.bodySmall),
                ],
              ),
              Builder(
                builder: (context) {
                  final business = ref.watch(businessProfileSyncProvider);
                  return CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      business?.initials ?? '??',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          dashboardAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, st) => Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
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
                    const Text(AppStrings.recentTransactions, style: AppTextStyles.heading3),
                    TextButton(
                      onPressed: () {
                        ref.read(_dashboardTabProvider.notifier).state = 3;
                      },
                      child: const Text(AppStrings.viewAll),
                    ),
                  ],
                ),
                if (data.recentTransactions.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text('Belum ada transaksi hari ini', style: AppTextStyles.bodySmall),
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
    );
  }
}

// ─── SERVICES TAB ──────────────────────────────────────────
class _ServicesTab extends ConsumerWidget {
  const _ServicesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(serviceListProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(AppStrings.services, style: AppTextStyles.heading1),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
                onPressed: () => context.push(RoutePaths.serviceForm),
              ),
            ],
          ),
        ),
        Expanded(
          child: servicesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
            data: (services) {
              if (services.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.work_outline, size: 64, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      const Text('Belum ada layanan', style: AppTextStyles.heading3),
                      const SizedBox(height: 8),
                      const Text('Tambahkan layanan jasa yang ditawarkan', style: AppTextStyles.bodySmall),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.push(RoutePaths.serviceForm),
                        icon: const Icon(Icons.add),
                        label: const Text(AppStrings.addService),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: service.isActive ? AppColors.primary : AppColors.textHint,
                        child: const Icon(Icons.work, color: Colors.white, size: 20),
                      ),
                      title: Text(
                        service.serviceName,
                        style: TextStyle(
                          decoration: service.isActive ? null : TextDecoration.lineThrough,
                        ),
                      ),
                      subtitle: Text('${service.category} - ${service.estimatedDuration}', style: AppTextStyles.bodySmall),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(CurrencyFormatter.format(service.price), style: AppTextStyles.price),
                          if (!service.isActive)
                            const Text('Nonaktif', style: TextStyle(fontSize: 10, color: AppColors.error)),
                        ],
                      ),
                      onTap: () => context.push('${RoutePaths.serviceForm}?serviceId=${service.serviceId}'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── CUSTOMERS TAB ─────────────────────────────────────────
class _CustomersTab extends ConsumerWidget {
  const _CustomersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customerListProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(AppStrings.customers, style: AppTextStyles.heading1),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
                onPressed: () => context.push(RoutePaths.customerForm),
              ),
            ],
          ),
        ),
        Expanded(
          child: customersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
            data: (customers) {
              if (customers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline, size: 64, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      const Text('Belum ada pelanggan', style: AppTextStyles.heading3),
                      const SizedBox(height: 8),
                      const Text('Tambahkan data pelanggan Anda', style: AppTextStyles.bodySmall),
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
                        child: Text(customer.initials, style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(customer.name),
                      subtitle: Text(customer.phoneNumber, style: AppTextStyles.bodySmall),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${customer.totalTransactions} transaksi', style: AppTextStyles.caption),
                          Text(
                            CurrencyFormatter.formatShort(customer.totalSpent),
                            style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
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
        ),
      ],
    );
  }
}

// ─── TRANSACTIONS TAB ──────────────────────────────────────
class _TransactionsTab extends ConsumerWidget {
  const _TransactionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(AppStrings.transactions, style: AppTextStyles.heading1),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
                onPressed: () => context.push(RoutePaths.transactionForm),
              ),
            ],
          ),
        ),
        Expanded(
          child: transactionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
            data: (transactions) {
              if (transactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long, size: 64, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      const Text('Belum ada transaksi', style: AppTextStyles.heading3),
                      const SizedBox(height: 8),
                      const Text('Buat transaksi pertama Anda', style: AppTextStyles.bodySmall),
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
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(t.customerSnapshot.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${t.invoiceNumber}', style: AppTextStyles.bodySmall),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              _StatusChip(label: _mapPaymentStatus(t.paymentStatus), color: _getPaymentStatusColor(t.paymentStatus)),
                              const SizedBox(width: 6),
                              _StatusChip(label: _mapJobStatus(t.jobStatus), color: _getJobStatusColor(t.jobStatus)),
                            ],
                          ),
                        ],
                      ),
                      trailing: Text(CurrencyFormatter.format(t.totalAmount), style: AppTextStyles.price),
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
        ),
      ],
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'paid': return AppColors.paid;
      case 'partial': return AppColors.partial;
      default: return AppColors.unpaid;
    }
  }

  Color _getJobStatusColor(String status) {
    switch (status) {
      case 'in_progress': return AppColors.inProgress;
      case 'done': return AppColors.done;
      case 'delivered': return AppColors.delivered;
      default: return AppColors.waiting;
    }
  }

  String _mapPaymentStatus(String status) {
    switch (status) {
      case 'paid': return AppStrings.paid;
      case 'partial': return AppStrings.partial;
      default: return AppStrings.unpaid;
    }
  }

  String _mapJobStatus(String status) {
    switch (status) {
      case 'in_progress': return AppStrings.inProgress;
      case 'done': return AppStrings.done;
      case 'delivered': return AppStrings.delivered;
      default: return AppStrings.waiting;
    }
  }
}

// ─── MORE TAB ──────────────────────────────────────────────
class _MoreTab extends ConsumerWidget {
  const _MoreTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(businessProfileSyncProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Lainnya', style: AppTextStyles.heading1),
        const SizedBox(height: 16),

        // Profile Header
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: business?.logoUrl != null ? NetworkImage(business!.logoUrl!) : null,
                  child: business?.logoUrl == null
                      ? Text(
                          business?.initials ?? '??',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business?.businessName ?? 'Usaha Anda',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        business?.ownerName ?? '',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Menu Items
        _MenuTile(
          icon: Icons.store,
          title: 'Profil Usaha',
          subtitle: 'Kelola data usaha Anda',
          onTap: () => context.push(RoutePaths.businessProfile),
        ),
        const Divider(height: 1),
        _MenuTile(
          icon: Icons.receipt,
          title: AppStrings.invoiceSettings,
          subtitle: 'Pengaturan nomor invoice',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur ini akan segera tersedia')),
            );
          },
        ),
        const Divider(height: 1),
        _MenuTile(
          icon: Icons.payment,
          title: AppStrings.bankAccountInfo,
          subtitle: 'Informasi rekening untuk pembayaran',
          onTap: () => context.push(RoutePaths.businessProfile),
        ),
        const Divider(height: 1),
        _MenuTile(
          icon: Icons.bar_chart,
          title: AppStrings.reports,
          subtitle: 'Laporan pendapatan',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur laporan akan segera tersedia')),
            );
          },
        ),
        const Divider(height: 1),
        _MenuTile(
          icon: Icons.info_outline,
          title: 'Tentang MISA',
          subtitle: 'Versi 1.0.0',
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'MISA',
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(Icons.receipt_long, size: 48, color: AppColors.primary),
              children: const [
                Text('Mobile Invoice & Service Application\nAplikasi untuk mengelola layanan jasa, pelanggan, transaksi, dan invoice.'),
              ],
            );
          },
        ),
        const Divider(height: 1),

        const SizedBox(height: 32),

        // Logout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Keluar'),
                  content: const Text('Yakin ingin keluar dari akun ini?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(AppStrings.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(AppStrings.logout, style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await ref.read(authNotifierProvider.notifier).logout();
                if (context.mounted) context.go(RoutePaths.login);
              }
            },
            icon: const Icon(Icons.logout, color: AppColors.error),
            label: const Text(AppStrings.logout, style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── WIDGETS ───────────────────────────────────────────────

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
                  Text(title, style: AppTextStyles.bodySmall),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
