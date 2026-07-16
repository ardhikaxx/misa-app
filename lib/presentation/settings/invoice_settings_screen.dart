import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/settings_provider.dart';
import '../../core/constants/app_text_styles.dart';

class InvoiceSettingsScreen extends ConsumerStatefulWidget {
  const InvoiceSettingsScreen({super.key});

  @override
  ConsumerState<InvoiceSettingsScreen> createState() =>
      _InvoiceSettingsScreenState();
}

class _InvoiceSettingsScreenState extends ConsumerState<InvoiceSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _prefixController;
  late TextEditingController _footerNoteController;
  bool _resetCounterMonthly = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _prefixController = TextEditingController();
    _footerNoteController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final settings = ref.read(invoiceSettingsSyncProvider);
      if (settings != null) {
        _prefixController.text = settings['invoicePrefix'] ?? 'INV';
        _footerNoteController.text = settings['invoiceFooterNote'] ?? '';
        _resetCounterMonthly = settings['resetCounterMonthly'] ?? false;
        _initialized = true;
      }
    }
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _footerNoteController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'invoicePrefix': _prefixController.text.trim(),
      'invoiceFooterNote': _footerNoteController.text.trim(),
      'resetCounterMonthly': _resetCounterMonthly,
    };

    await ref.read(invoiceSettingsUpdateProvider.notifier).updateInvoiceSettings(data);

    if (mounted) {
      final state = ref.read(invoiceSettingsUpdateProvider);
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
            content: Text('Pengaturan invoice berhasil disimpan'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(invoiceSettingsUpdateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.invoiceSettings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pengaturan Nomor Invoice',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _prefixController,
                validator: (v) => Validators.required(v, AppStrings.invoicePrefix),
                decoration: const InputDecoration(
                  labelText: AppStrings.invoicePrefix,
                  prefixIcon: Icon(Icons.tag),
                  hintText: 'Contoh: INV',
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Reset nomor setiap bulan'),
                subtitle: const Text(
                  'Nomor invoice akan dimulai dari 001 setiap bulan',
                  style: AppTextStyles.bodySmall,
                ),
                value: _resetCounterMonthly,
                onChanged: (value) {
                  setState(() {
                    _resetCounterMonthly = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              Text(
                'Tampilan Invoice',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _footerNoteController,
                maxLines: 3,
                validator: (v) => Validators.required(v, AppStrings.invoiceFooterNote),
                decoration: const InputDecoration(
                  labelText: AppStrings.invoiceFooterNote,
                  prefixIcon: Icon(Icons.note),
                  alignLabelWithHint: true,
                  hintText: 'Contoh: Terima kasih telah menggunakan jasa kami',
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: updateState.isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
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
