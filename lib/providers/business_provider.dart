import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business_model.dart';
import '../services/storage_service.dart';
import 'auth_provider.dart';

final businessProfileProvider = StreamProvider<BusinessModel?>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(businessServiceProvider).watchBusiness(uid);
});

final businessProfileSyncProvider = Provider<BusinessModel?>((ref) {
  return ref.watch(businessProfileProvider).valueOrNull;
});

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

final businessSetupProvider =
    StateNotifierProvider<BusinessSetupNotifier, AsyncValue<void>>((ref) {
  return BusinessSetupNotifier(ref);
});

class BusinessSetupNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  BusinessSetupNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> setup({
    required String ownerName,
    required String businessName,
    required String businessCategory,
    required String address,
    required String whatsappNumber,
  }) async {
    state = const AsyncValue.loading();
    try {
      final uid = ref.read(currentUserIdProvider);
      if (uid == null) throw Exception('User tidak ditemukan');
      await ref.read(businessServiceProvider).updateBusiness(uid, {
        'ownerName': ownerName,
        'businessName': businessName,
        'businessCategory': businessCategory,
        'address': address,
        'whatsappNumber': whatsappNumber,
      });
      await ref.read(businessServiceProvider).completeSetup(uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final businessUpdateProvider =
    StateNotifierProvider<BusinessUpdateNotifier, AsyncValue<void>>((ref) {
  return BusinessUpdateNotifier(ref);
});

class BusinessUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  BusinessUpdateNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final uid = ref.read(currentUserIdProvider);
      if (uid == null) throw Exception('User tidak ditemukan');
      await ref.read(businessServiceProvider).updateBusiness(uid, data);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> uploadLogo(File file) async {
    state = const AsyncValue.loading();
    try {
      final uid = ref.read(currentUserIdProvider);
      if (uid == null) throw Exception('User tidak ditemukan');
      final url = await ref.read(storageServiceProvider).uploadLogo(uid, file);
      await ref.read(businessServiceProvider).updateLogo(uid, url);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> uploadQris(File file) async {
    state = const AsyncValue.loading();
    try {
      final uid = ref.read(currentUserIdProvider);
      if (uid == null) throw Exception('User tidak ditemukan');
      final url = await ref.read(storageServiceProvider).uploadQrisImage(uid, file);
      await ref.read(businessServiceProvider).updateBusiness(uid, {'qrisImageUrl': url});
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
