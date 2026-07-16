import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/service_catalog_provider.dart';

class ServiceFormScreen extends ConsumerStatefulWidget {
  const ServiceFormScreen({super.key});

  @override
  ConsumerState<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends ConsumerState<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _descriptionController;
  bool _isEdit = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _categoryController = TextEditingController();
    _priceController = TextEditingController();
    _durationController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    final uri = GoRouterState.of(context).uri;
    final serviceId = uri.queryParameters['serviceId'];

    if (serviceId != null) {
      _isEdit = true;
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadService(serviceId);
      });
    } else {
      _loaded = true;
      ref.read(serviceFormProvider.notifier).reset();
    }
  }

  void _loadService(String serviceId) async {
    final services = ref.read(serviceListProvider).valueOrNull;
    if (services == null || services.isEmpty) return;

    try {
      final service = services.firstWhere(
        (s) => s.serviceId == serviceId,
      );
      ref.read(serviceFormProvider.notifier).loadService(service);
      setState(() {
        _nameController.text = service.serviceName;
        _categoryController.text = service.category;
        _priceController.text = service.price.toString();
        _durationController.text = service.estimatedDuration;
        _descriptionController.text = service.description ?? '';
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Layanan tidak ditemukan'),
            backgroundColor: AppColors.error,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(serviceFormProvider.notifier);
    notifier.updateName(_nameController.text.trim());
    notifier.updateCategory(_categoryController.text.trim());
    notifier.updatePrice(int.tryParse(_priceController.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0);
    notifier.updateDuration(_durationController.text.trim());
    notifier.updateDescription(_descriptionController.text.trim());

    final success = await notifier.save();
    if (!mounted) return;
    if (success) {
      ref.invalidate(serviceListProvider);
      if (context.mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Layanan berhasil disimpan'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      if (context.mounted) {
        final state = ref.read(serviceFormProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage ?? 'Gagal menyimpan'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(serviceFormProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? AppStrings.editService : AppStrings.addService),
        actions: [
          if (_isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Hapus Layanan'),
                    content: const Text('Yakin ingin menghapus layanan ini?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(AppStrings.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(AppStrings.delete,
                            style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && mounted) {
                  await ref.read(serviceFormProvider.notifier).delete();
                  ref.invalidate(serviceListProvider);
                  if (context.mounted) context.pop();
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                validator: (v) => Validators.required(v, 'Nama layanan'),
                decoration: const InputDecoration(
                  labelText: AppStrings.serviceName,
                  hintText: 'Contoh: Servis AC 1 PK',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                validator: (v) => Validators.required(v, 'Kategori'),
                decoration: const InputDecoration(
                  labelText: AppStrings.category,
                  hintText: 'Contoh: Perbaikan',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                validator: Validators.price,
                decoration: const InputDecoration(
                  labelText: AppStrings.price,
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: AppStrings.estimatedDuration,
                  hintText: 'Contoh: 1-2 jam',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: AppStrings.description,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: formState.isSubmitting ? null : _handleSave,
                child: formState.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(AppStrings.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
