import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../models/business_model.dart';
import '../../providers/business_provider.dart';
import '../../routing/route_paths.dart';
import '../../core/constants/app_text_styles.dart';

class BusinessSetupScreen extends ConsumerStatefulWidget {
  const BusinessSetupScreen({super.key});

  @override
  ConsumerState<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends ConsumerState<BusinessSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _whatsappController = TextEditingController();
  String _selectedCategory = '';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _ownerNameController.dispose();
    _businessNameController.dispose();
    _addressController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _handleSetup() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori usaha'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(businessSetupProvider.notifier).setup(
            ownerName: _ownerNameController.text.trim(),
            businessName: _businessNameController.text.trim(),
            businessCategory: _selectedCategory,
            address: _addressController.text.trim(),
            whatsappNumber: _whatsappController.text.trim(),
          );

      if (!mounted) return;

      final state = ref.read(businessSetupProvider);
      if (state.hasError) {
        setState(() => _isSubmitting = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan: ${state.error}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } else {
        if (mounted) {
          context.go(RoutePaths.dashboard);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Icon(
                  Icons.store,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  AppStrings.setupBusiness,
                  style: AppTextStyles.heading1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lengkapi data usaha Anda untuk mulai menggunakan MISA',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _ownerNameController,
                  validator: (value) => Validators.required(value, 'Nama pemilik'),
                  decoration: const InputDecoration(
                    labelText: AppStrings.ownerName,
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _businessNameController,
                  validator: (value) => Validators.required(value, 'Nama usaha'),
                  decoration: const InputDecoration(
                    labelText: AppStrings.businessName,
                    prefixIcon: Icon(Icons.store_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCategory.isEmpty ? null : _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: AppStrings.businessCategory,
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: BusinessCategory.values
                      .map((cat) => DropdownMenuItem(
                            value: cat.label,
                            child: Text(cat.label),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value ?? '';
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  validator: (value) => Validators.required(value, 'Alamat'),
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: AppStrings.address,
                    prefixIcon: Icon(Icons.location_on_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _whatsappController,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phoneIndonesian,
                  decoration: const InputDecoration(
                    labelText: AppStrings.whatsappNumber,
                    prefixIcon: Icon(Icons.phone_outlined),
                    hintText: '08xxxxxxxxxx',
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSetup,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(AppStrings.finishSetup),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
