import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer_model.dart';
import '../services/customer_service.dart';
import 'auth_provider.dart';

final customerServiceProvider = Provider<CustomerService>(
    (ref) => CustomerService());

final customerListProvider = StreamProvider<List<CustomerModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(customerServiceProvider).watchCustomers(uid);
});

final customerFormProvider =
    StateNotifierProvider<CustomerFormNotifier, CustomerFormState>((ref) {
  return CustomerFormNotifier(ref);
});

class CustomerFormState {
  final String? customerId;
  final String name;
  final String phoneNumber;
  final String email;
  final String address;
  final String notes;
  final bool isSubmitting;
  final String? errorMessage;

  const CustomerFormState({
    this.customerId,
    this.name = '',
    this.phoneNumber = '',
    this.email = '',
    this.address = '',
    this.notes = '',
    this.isSubmitting = false,
    this.errorMessage,
  });

  CustomerFormState copyWith({
    String? customerId,
    String? name,
    String? phoneNumber,
    String? email,
    String? address,
    String? notes,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return CustomerFormState(
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CustomerFormNotifier extends StateNotifier<CustomerFormState> {
  final Ref ref;
  CustomerFormNotifier(this.ref) : super(const CustomerFormState());

  void loadCustomer(CustomerModel customer) {
    state = CustomerFormState(
      customerId: customer.customerId,
      name: customer.name,
      phoneNumber: customer.phoneNumber,
      email: customer.email ?? '',
      address: customer.address ?? '',
      notes: customer.notes ?? '',
    );
  }

  void reset() => state = const CustomerFormState();
  void updateName(String v) => state = state.copyWith(name: v);
  void updatePhone(String v) => state = state.copyWith(phoneNumber: v);
  void updateEmail(String v) => state = state.copyWith(email: v);
  void updateAddress(String v) => state = state.copyWith(address: v);
  void updateNotes(String v) => state = state.copyWith(notes: v);

  Future<bool> save() async {
    state = CustomerFormState(
      customerId: state.customerId,
      name: state.name,
      phoneNumber: state.phoneNumber,
      email: state.email,
      address: state.address,
      notes: state.notes,
      isSubmitting: true,
    );
    try {
      final uid = ref.read(currentUserIdProvider);
      if (uid == null) throw Exception('User tidak ditemukan');
      final service = ref.read(customerServiceProvider);
      final now = DateTime.now();

      if (state.customerId != null) {
        await service.updateCustomer(uid, state.customerId!, {
          'name': state.name,
          'phoneNumber': state.phoneNumber,
          'email': state.email.isEmpty ? null : state.email,
          'address': state.address.isEmpty ? null : state.address,
          'notes': state.notes.isEmpty ? null : state.notes,
        });
      } else {
        await service.createCustomer(uid, CustomerModel(
          customerId: '', name: state.name, phoneNumber: state.phoneNumber,
          email: state.email.isEmpty ? null : state.email,
          address: state.address.isEmpty ? null : state.address,
          notes: state.notes.isEmpty ? null : state.notes,
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

  Future<void> delete() async {
    if (state.customerId == null) return;
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    await ref.read(customerServiceProvider).deleteCustomer(uid, state.customerId!);
  }
}
