import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/transaction_service.dart';
import 'auth_provider.dart';

final settingsServiceProvider = Provider<TransactionService>((ref) => TransactionService());

final invoiceSettingsProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(settingsServiceProvider).watchSettings(uid);
});

final invoiceSettingsSyncProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(invoiceSettingsProvider).valueOrNull;
});

final invoiceSettingsUpdateProvider =
    StateNotifierProvider<InvoiceSettingsUpdateNotifier, AsyncValue<void>>((ref) {
  return InvoiceSettingsUpdateNotifier(ref);
});

class InvoiceSettingsUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  InvoiceSettingsUpdateNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> updateInvoiceSettings(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final uid = ref.read(currentUserIdProvider);
      if (uid == null) throw Exception('User tidak ditemukan');
      await ref.read(settingsServiceProvider).updateSettings(uid, data);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
