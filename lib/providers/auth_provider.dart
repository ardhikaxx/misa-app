import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/business_model.dart';
import '../services/auth_service.dart';
import '../services/business_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final businessServiceProvider = Provider<BusinessService>((ref) => BusinessService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.uid;
});

final businessSetupStatusProvider = StreamProvider<bool>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(false);
  return ref.watch(businessServiceProvider).watchBusiness(uid).map(
    (business) => business?.isSetupComplete ?? false,
  );
});

final isSetupCompleteProvider = Provider<bool>((ref) {
  return ref.watch(businessSetupStatusProvider).valueOrNull ?? false;
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  AuthNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authServiceProvider).signInWithEmail(email, password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final credential = await ref.read(authServiceProvider).registerWithEmail(email, password);
      final user = credential.user;
      if (user != null) {
        final now = DateTime.now();
        final business = BusinessModel(
          businessId: user.uid,
          ownerName: '',
          businessName: '',
          businessCategory: '',
          address: '',
          whatsappNumber: '',
          email: user.email ?? '',
          createdAt: now,
          updatedAt: now,
          isSetupComplete: false,
        );
        await ref.read(businessServiceProvider).createBusiness(user.uid, business);
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loginWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final credential = await ref.read(authServiceProvider).signInWithGoogle();
      final user = credential.user;
      if (user != null) {
        final existing = await ref.read(businessServiceProvider).getBusiness(user.uid);
        if (existing == null) {
          final now = DateTime.now();
          final business = BusinessModel(
            businessId: user.uid,
            ownerName: user.displayName ?? '',
            businessName: '',
            businessCategory: '',
            address: '',
            whatsappNumber: '',
            email: user.email ?? '',
            createdAt: now,
            updatedAt: now,
            isSetupComplete: false,
          );
          await ref.read(businessServiceProvider).createBusiness(user.uid, business);
        }
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await ref.read(authServiceProvider).sendPasswordResetEmail(email);
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).signOut();
    ref.invalidate(authStateProvider);
    ref.invalidate(currentUserProvider);
    ref.invalidate(currentUserIdProvider);
    ref.invalidate(businessSetupStatusProvider);
  }
}
