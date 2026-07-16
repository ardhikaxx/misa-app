import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/service_catalog_provider.dart';
import '../../routing/route_paths.dart';
import '../../core/constants/app_text_styles.dart';

class ServiceListScreen extends ConsumerWidget {
  const ServiceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(serviceListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.services),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(RoutePaths.serviceForm),
          ),
        ],
      ),
      body: servicesAsync.when(
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
                  const Text(
                    'Belum ada layanan',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tambahkan layanan jasa yang ditawarkan',
                    style: AppTextStyles.bodySmall,
                  ),
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
                    backgroundColor: service.isActive
                        ? AppColors.primary
                        : AppColors.textHint,
                    child: const Icon(
                      Icons.work,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    service.serviceName,
                    style: TextStyle(
                      decoration: service.isActive
                          ? null
                          : TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: Text(
                    '${service.category} - ${service.estimatedDuration}',
                    style: AppTextStyles.bodySmall,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.format(service.price),
                        style: AppTextStyles.price,
                      ),
                      if (!service.isActive)
                        const Text(
                          'Nonaktif',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.error,
                          ),
                        ),
                    ],
                  ),
                  onTap: () => context.push(
                    '${RoutePaths.serviceForm}?serviceId=${service.serviceId}',
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
