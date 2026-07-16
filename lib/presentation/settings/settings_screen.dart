import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';
import '../../routing/route_paths.dart';
import '../../core/constants/app_text_styles.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(businessProfileSyncProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: ListView(
        children: [
          // Business Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            color: AppColors.primary,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    business?.initials ?? '??',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  business?.businessName ?? 'Belum diatur',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  business?.ownerName ?? '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Settings Menu
          _SettingsTile(
            icon: Icons.store,
            title: AppStrings.businessProfile,
            subtitle: 'Kelola data usaha Anda',
            onTap: () => context.push(RoutePaths.businessProfile),
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.receipt,
            title: AppStrings.invoiceSettings,
            subtitle: 'Pengaturan nomor invoice dan catatan',
            onTap: () {
              // TODO: Implement invoice settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur ini akan segera tersedia'),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.payment,
            title: AppStrings.bankAccountInfo,
            subtitle: 'Informasi rekening untuk pembayaran',
            onTap: () {
              // TODO: Implement bank account settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur ini akan segera tersedia'),
                ),
              );
            },
          ),
          const Divider(height: 1),

          const SizedBox(height: 24),

          // About
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'Tentang MISA',
            subtitle: 'Versi 1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'MISA',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(
                  Icons.receipt_long,
                  size: 48,
                  color: AppColors.primary,
                ),
                children: const [
                  Text(
                    'Mobile Invoice & Service Application\n'
                    'Aplikasi untuk mengelola layanan jasa, '
                    'pelanggan, transaksi, dan invoice.',
                  ),
                ],
              );
            },
          ),
          const Divider(height: 1),

          const SizedBox(height: 24),

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
                        child: const Text(
                          AppStrings.logout,
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await ref.read(authNotifierProvider.notifier).logout();
                }
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text(
                AppStrings.logout,
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
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
