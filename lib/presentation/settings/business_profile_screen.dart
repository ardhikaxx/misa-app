import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../models/business_model.dart';
import '../../providers/business_provider.dart';
import '../../core/constants/app_text_styles.dart';

class BusinessProfileScreen extends ConsumerStatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  ConsumerState<BusinessProfileScreen> createState() =>
      _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends ConsumerState<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ownerNameController;
  late TextEditingController _businessNameController;
  late TextEditingController _addressController;
  late TextEditingController _whatsappController;
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _accountHolderController;
  String _selectedCategory = '';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _ownerNameController = TextEditingController();
    _businessNameController = TextEditingController();
    _addressController = TextEditingController();
    _whatsappController = TextEditingController();
    _bankNameController = TextEditingController();
    _accountNumberController = TextEditingController();
    _accountHolderController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final business = ref.read(businessProfileSyncProvider);
      if (business != null) {
        _ownerNameController.text = business.ownerName;
        _businessNameController.text = business.businessName;
        _addressController.text = business.address;
        _whatsappController.text = business.whatsappNumber;
        _selectedCategory = business.businessCategory;
        if (business.bankAccountInfo != null) {
          _bankNameController.text = business.bankAccountInfo!['bankName'] ?? '';
          _accountNumberController.text =
              business.bankAccountInfo!['accountNumber'] ?? '';
          _accountHolderController.text =
              business.bankAccountInfo!['accountHolder'] ?? '';
        }
        _initialized = true;
      }
    }
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _businessNameController.dispose();
    _addressController.dispose();
    _whatsappController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image != null && mounted) {
      await ref
          .read(businessUpdateProvider.notifier)
          .uploadLogo(File(image.path));
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'ownerName': _ownerNameController.text.trim(),
      'businessName': _businessNameController.text.trim(),
      'businessCategory': _selectedCategory,
      'address': _addressController.text.trim(),
      'whatsappNumber': _whatsappController.text.trim(),
      'bankAccountInfo': {
        'bankName': _bankNameController.text.trim(),
        'accountNumber': _accountNumberController.text.trim(),
        'accountHolder': _accountHolderController.text.trim(),
      },
    };

    await ref.read(businessUpdateProvider.notifier).updateProfile(data);

    if (mounted) {
      final state = ref.read(businessUpdateProvider);
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil usaha berhasil disimpan'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(businessUpdateProvider);
    final business = ref.watch(businessProfileSyncProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.businessProfile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Logo
              GestureDetector(
                onTap: _pickLogo,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: business?.logoUrl != null
                      ? NetworkImage(business!.logoUrl!)
                      : null,
                  child: business?.logoUrl == null
                      ? const Icon(Icons.camera_alt,
                          size: 32, color: AppColors.primary)
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ketuk untuk mengganti logo',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 24),

              // Form Fields
              TextFormField(
                controller: _ownerNameController,
                validator: (v) => Validators.required(v, 'Nama pemilik'),
                decoration: const InputDecoration(
                  labelText: AppStrings.ownerName,
                  prefixIcon: Icon(Icons.person_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _businessNameController,
                validator: (v) => Validators.required(v, 'Nama usaha'),
                decoration: const InputDecoration(
                  labelText: AppStrings.businessName,
                  prefixIcon: Icon(Icons.store_outlined),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory.isEmpty ? null : _selectedCategory,
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
                validator: (v) => Validators.required(v, 'Alamat'),
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
              const SizedBox(height: 24),

              // Bank Account Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppStrings.bankAccountInfo,
                  style: AppTextStyles.heading3,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  labelText: AppStrings.bankName,
                  prefixIcon: Icon(Icons.account_balance),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: AppStrings.accountNumber,
                  prefixIcon: Icon(Icons.credit_card),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _accountHolderController,
                decoration: const InputDecoration(
                  labelText: AppStrings.accountHolder,
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: updateState.isLoading ? null : _handleSave,
                child: updateState.isLoading
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
