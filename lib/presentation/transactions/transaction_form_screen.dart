import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/customer_model.dart';
import '../../models/service_model.dart';
import '../../models/transaction_item_model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/service_catalog_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../core/constants/app_text_styles.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _discountController = TextEditingController();
  final _discountNoteController = TextEditingController();
  final _additionalFeeController = TextEditingController();
  final _additionalFeeNoteController = TextEditingController();
  final _notesController = TextEditingController();

  CustomerModel? _selectedCustomer;
  final List<_ItemEntry> _items = [];

  @override
  void dispose() {
    _discountController.dispose();
    _discountNoteController.dispose();
    _additionalFeeController.dispose();
    _additionalFeeNoteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showCustomerPicker() {
    final customers = ref.read(customerListProvider).valueOrNull ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(AppStrings.selectCustomer,
                  style: AppTextStyles.heading3),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        customer.initials,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(customer.name),
                    subtitle: Text(customer.phoneNumber),
                    onTap: () {
                      setState(() {
                        _selectedCustomer = customer;
                      });
                      ref
                          .read(transactionFormProvider.notifier)
                          .selectCustomer(customer);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showServicePicker() {
    final services = ref.read(activeServiceListProvider).valueOrNull ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(AppStrings.selectService,
                  style: AppTextStyles.heading3),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return ListTile(
                    title: Text(service.serviceName),
                    subtitle: Text(
                        '${service.category} - ${CurrencyFormatter.format(service.price)}'),
                    trailing: const Icon(Icons.add_circle_outline),
                    onTap: () {
                      Navigator.pop(context);
                      _showQuantityDialog(service);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuantityDialog(ServiceModel service) {
    int quantity = 1;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(service.serviceName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Harga: ${CurrencyFormatter.format(service.price)}'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: quantity > 1
                        ? () => setDialogState(() => quantity--)
                        : null,
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setDialogState(() => quantity++),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Subtotal: ${CurrencyFormatter.format(service.price * quantity)}',
                style: AppTextStyles.price,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final item = TransactionItemModel.calculate(
                  serviceId: service.serviceId,
                  serviceName: service.serviceName,
                  price: service.price,
                  quantity: quantity,
                );
                setState(() {
                  _items.add(_ItemEntry(item: item));
                });
                ref.read(transactionFormProvider.notifier).addItem(item);
                Navigator.pop(context);
              },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    ref.read(transactionFormProvider.notifier).removeItem(index);
  }

  Future<void> _handleSave() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.noCustomerSelected),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.selectAtLeastOneService),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final notifier = ref.read(transactionFormProvider.notifier);
    notifier.updateDiscount(
        int.tryParse(_discountController.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0);
    notifier.updateDiscountNote(_discountNoteController.text.trim());
    notifier.updateAdditionalFee(
        int.tryParse(_additionalFeeController.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0);
    notifier.updateAdditionalFeeNote(_additionalFeeNoteController.text.trim());
    notifier.updateNotes(_notesController.text.trim());

    final success = await notifier.save();
    if (mounted) {
      if (success) {
        ref.invalidate(transactionListProvider);
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil disimpan'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        final state = ref.read(transactionFormProvider);
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
    final formState = ref.watch(transactionFormProvider);
    final subtotal = formState.subtotal;
    final total = formState.totalAmount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.addTransaction),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    _selectedCustomer?.name ?? AppStrings.selectCustomer,
                    style: TextStyle(
                      color: _selectedCustomer != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showCustomerPicker,
                ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Items (${_items.length})',
                            style: AppTextStyles.heading3,
                          ),
                          TextButton.icon(
                            onPressed: _showServicePicker,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text(AppStrings.addItem),
                          ),
                        ],
                      ),
                      if (_items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'Belum ada item',
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        )
                      else
                        ..._items.asMap().entries.map((entry) {
                          final item = entry.value.item;
                          return ListTile(
                            dense: true,
                            title: Text(item.serviceName),
                            subtitle: Text(
                              '${item.quantity} x ${CurrencyFormatter.format(item.price)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(CurrencyFormatter.format(item.lineTotal)),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      size: 18, color: AppColors.error),
                                  onPressed: () => _removeItem(entry.key),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _discountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: AppStrings.discount,
                          prefixText: 'Rp ',
                          prefixIcon: Icon(Icons.discount_outlined),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _discountNoteController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.discountNote,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _additionalFeeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: AppStrings.additionalFee,
                          prefixText: 'Rp ',
                          prefixIcon: Icon(Icons.add_circle_outline),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _additionalFeeNoteController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.additionalFeeNote,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: formState.paymentMethod,
                        decoration: const InputDecoration(
                          labelText: AppStrings.paymentMethod,
                          prefixIcon: Icon(Icons.payment),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'cash', child: Text('Tunai')),
                          DropdownMenuItem(
                              value: 'transfer', child: Text('Transfer')),
                          DropdownMenuItem(
                              value: 'qris', child: Text('QRIS')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(transactionFormProvider.notifier)
                                .updatePaymentMethod(value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: formState.paymentStatus,
                        decoration: const InputDecoration(
                          labelText: AppStrings.paymentStatus,
                          prefixIcon: Icon(Icons.check_circle_outline),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'unpaid', child: Text('Belum Dibayar')),
                          DropdownMenuItem(
                              value: 'partial', child: Text('Bayar Sebagian')),
                          DropdownMenuItem(
                              value: 'paid', child: Text('Lunas')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(transactionFormProvider.notifier)
                                .updatePaymentStatus(value);
                          }
                        },
                      ),
                      if (formState.paymentStatus == 'partial') ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: AppStrings.amountPaid,
                            prefixText: 'Rp ',
                          ),
                          onChanged: (value) {
                            final amount =
                                int.tryParse(value.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
                            ref
                                .read(transactionFormProvider.notifier)
                                .updateAmountPaid(amount);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: AppStrings.notes,
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _SummaryRow(
                          label: AppStrings.subtotal,
                          value: CurrencyFormatter.format(subtotal)),
                      _SummaryRow(
                        label: AppStrings.discount,
                        value:
                            '-${CurrencyFormatter.format(formState.discountAmount)}',
                      ),
                      _SummaryRow(
                        label: AppStrings.additionalFee,
                        value:
                            CurrencyFormatter.format(formState.additionalFee),
                      ),
                      const Divider(),
                      _SummaryRow(
                        label: AppStrings.totalAmount,
                        value: CurrencyFormatter.format(total),
                        isBold: true,
                      ),
                    ],
                  ),
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

class _ItemEntry {
  final TransactionItemModel item;
  _ItemEntry({required this.item});
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: isBold ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
