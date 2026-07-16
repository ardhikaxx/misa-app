import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/transaction_service.dart';
import '../services/customer_service.dart';
import '../models/transaction_model.dart';
import '../models/transaction_item_model.dart';
import 'auth_provider.dart';

final transactionServiceProvider = Provider<TransactionService>(
    (ref) => TransactionService());

final customerServiceProvider = Provider<CustomerService>(
    (ref) => CustomerService());

final transactionListProvider = StreamProvider<List<TransactionModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(transactionServiceProvider).watchTransactions(uid);
});

final transactionFormProvider =
    StateNotifierProvider<TransactionFormNotifier, TransactionFormState>(
        (ref) => TransactionFormNotifier(ref));

class TransactionFormState {
  final String? transactionId;
  final String customerId;
  final CustomerSnapshot? customerSnapshot;
  final List<TransactionItemModel> items;
  final int discountAmount;
  final String discountNote;
  final int additionalFee;
  final String additionalFeeNote;
  final String paymentMethod;
  final String paymentStatus;
  final int amountPaid;
  final String jobStatus;
  final String notes;
  final bool isSubmitting;
  final String? errorMessage;

  const TransactionFormState({
    this.transactionId,
    this.customerId = '',
    this.customerSnapshot,
    this.items = const [],
    this.discountAmount = 0,
    this.discountNote = '',
    this.additionalFee = 0,
    this.additionalFeeNote = '',
    this.paymentMethod = 'cash',
    this.paymentStatus = 'unpaid',
    this.amountPaid = 0,
    this.jobStatus = 'waiting',
    this.notes = '',
    this.isSubmitting = false,
    this.errorMessage,
  });

  int get subtotal => items.fold(0, (acc, item) => acc + item.lineTotal);
  int get totalAmount => subtotal - discountAmount + additionalFee;

  TransactionFormState copyWith({
    String? transactionId,
    String? customerId,
    CustomerSnapshot? customerSnapshot,
    List<TransactionItemModel>? items,
    int? discountAmount,
    String? discountNote,
    int? additionalFee,
    String? additionalFeeNote,
    String? paymentMethod,
    String? paymentStatus,
    int? amountPaid,
    String? jobStatus,
    String? notes,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return TransactionFormState(
      transactionId: transactionId ?? this.transactionId,
      customerId: customerId ?? this.customerId,
      customerSnapshot: customerSnapshot ?? this.customerSnapshot,
      items: items ?? this.items,
      discountAmount: discountAmount ?? this.discountAmount,
      discountNote: discountNote ?? this.discountNote,
      additionalFee: additionalFee ?? this.additionalFee,
      additionalFeeNote: additionalFeeNote ?? this.additionalFeeNote,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amountPaid: amountPaid ?? this.amountPaid,
      jobStatus: jobStatus ?? this.jobStatus,
      notes: notes ?? this.notes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class TransactionFormNotifier extends StateNotifier<TransactionFormState> {
  final Ref ref;
  TransactionFormNotifier(this.ref) : super(const TransactionFormState());

  void selectCustomer(dynamic c) => state = state.copyWith(
    customerId: c.customerId,
    customerSnapshot: CustomerSnapshot(name: c.name, phoneNumber: c.phoneNumber, address: c.address),
  );

  void addItem(TransactionItemModel item) =>
      state = state.copyWith(items: [...state.items, item]);

  void removeItem(int i) =>
      state = state.copyWith(items: [...state.items]..removeAt(i));

  void updateDiscount(int v) => state = state.copyWith(discountAmount: v);
  void updateDiscountNote(String v) => state = state.copyWith(discountNote: v);
  void updateAdditionalFee(int v) => state = state.copyWith(additionalFee: v);
  void updateAdditionalFeeNote(String v) => state = state.copyWith(additionalFeeNote: v);
  void updatePaymentMethod(String v) => state = state.copyWith(paymentMethod: v);
  void updatePaymentStatus(String v) {
    int p = state.amountPaid;
    if (v == 'paid') p = state.totalAmount;
    state = state.copyWith(paymentStatus: v, amountPaid: p);
  }
  void updateAmountPaid(int v) => state = state.copyWith(amountPaid: v);
  void updateJobStatus(String v) => state = state.copyWith(jobStatus: v);
  void updateNotes(String v) => state = state.copyWith(notes: v);
  void reset() => state = const TransactionFormState();

  Future<bool> save() async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final uid = ref.read(currentUserIdProvider);
      if (uid == null) throw Exception('User tidak ditemukan');
      if (state.customerId.isEmpty) throw Exception('Pilih pelanggan terlebih dahulu');
      if (state.items.isEmpty) throw Exception('Pilih minimal satu layanan');

      final service = ref.read(transactionServiceProvider);
      final now = DateTime.now();

      if (state.transactionId != null) {
        await service.updateTransaction(uid, state.transactionId!, {
          'customerId': state.customerId,
          'customerSnapshot': state.customerSnapshot?.toMap(),
          'items': state.items.map((e) => e.toMap()).toList(),
          'subtotal': state.subtotal, 'discountAmount': state.discountAmount,
          'discountNote': state.discountNote.isEmpty ? null : state.discountNote,
          'additionalFee': state.additionalFee,
          'additionalFeeNote': state.additionalFeeNote.isEmpty ? null : state.additionalFeeNote,
          'totalAmount': state.totalAmount, 'paymentMethod': state.paymentMethod,
          'paymentStatus': state.paymentStatus, 'amountPaid': state.amountPaid,
          'jobStatus': state.jobStatus, 'notes': state.notes.isEmpty ? null : state.notes,
        });
      } else {
        final invoiceNumber = await service.generateInvoiceNumber(uid, 'MISA');
        await service.createTransaction(uid, TransactionModel(
          transactionId: '', invoiceNumber: invoiceNumber, transactionDate: now,
          customerId: state.customerId, customerSnapshot: state.customerSnapshot!,
          items: state.items, subtotal: state.subtotal,
          discountAmount: state.discountAmount,
          discountNote: state.discountNote.isEmpty ? null : state.discountNote,
          additionalFee: state.additionalFee,
          additionalFeeNote: state.additionalFeeNote.isEmpty ? null : state.additionalFeeNote,
          totalAmount: state.totalAmount, paymentMethod: state.paymentMethod,
          paymentStatus: state.paymentStatus, amountPaid: state.amountPaid,
          jobStatus: state.jobStatus, notes: state.notes.isEmpty ? null : state.notes,
          createdAt: now, updatedAt: now,
        ));
      }
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }
}
