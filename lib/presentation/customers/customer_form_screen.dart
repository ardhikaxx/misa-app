import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/app_toast.dart';
import '../../providers/customer_provider.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({super.key});

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;
  bool _isEdit = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    final uri = GoRouterState.of(context).uri;
    final customerId = uri.queryParameters['customerId'];

    if (customerId != null) {
      _isEdit = true;
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadCustomer(customerId);
      });
    } else {
      _loaded = true;
      ref.read(customerFormProvider.notifier).reset();
    }
  }

  void _loadCustomer(String customerId) async {
    final customers = ref.read(customerListProvider).valueOrNull;
    if (customers == null || customers.isEmpty) return;

    try {
      final customer = customers.firstWhere(
        (c) => c.customerId == customerId,
      );
      ref.read(customerFormProvider.notifier).loadCustomer(customer);
      setState(() {
        _nameController.text = customer.name;
        _phoneController.text = customer.phoneNumber;
        _emailController.text = customer.email ?? '';
        _addressController.text = customer.address ?? '';
        _notesController.text = customer.notes ?? '';
      });
    } catch (_) {
      if (mounted) {
        AppToast.error(context, 'Pelanggan tidak ditemukan');
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(customerFormProvider.notifier);
    notifier.updateName(_nameController.text.trim());
    notifier.updatePhone(_phoneController.text.trim());
    notifier.updateEmail(_emailController.text.trim());
    notifier.updateAddress(_addressController.text.trim());
    notifier.updateNotes(_notesController.text.trim());

    final success = await notifier.save();
    if (mounted) {
      if (success) {
        ref.invalidate(customerListProvider);
        if (context.mounted) {
          AppToast.success(context, 'Pelanggan berhasil disimpan');
          context.pop();
        }
      } else {
        final state = ref.read(customerFormProvider);
        if (context.mounted) {
          AppToast.error(context, state.errorMessage ?? 'Gagal menyimpan');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(customerFormProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? AppStrings.editCustomer : AppStrings.addCustomer),
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
                validator: (v) => Validators.required(v, 'Nama pelanggan'),
                decoration: const InputDecoration(
                  labelText: AppStrings.customerName,
                  prefixIcon: Icon(Icons.person_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: Validators.phoneIndonesian,
                decoration: const InputDecoration(
                  labelText: AppStrings.phoneNumber,
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: '08xxxxxxxxxx',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    return Validators.email(v);
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: AppStrings.customerEmail,
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: AppStrings.customerAddress,
                  prefixIcon: Icon(Icons.location_on_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: AppStrings.customerNotes,
                  prefixIcon: Icon(Icons.notes),
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
