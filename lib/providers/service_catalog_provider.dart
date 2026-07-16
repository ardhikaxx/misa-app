import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_model.dart';
import '../services/service_catalog_service.dart';
import 'auth_provider.dart';

final serviceCatalogServiceProvider = Provider<ServiceCatalogService>(
    (ref) => ServiceCatalogService());

final serviceListProvider = StreamProvider<List<ServiceModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value([]);

  final service = ref.watch(serviceCatalogServiceProvider);
  return service.watchServices(uid);
});

final activeServiceListProvider = StreamProvider<List<ServiceModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value([]);

  final service = ref.watch(serviceCatalogServiceProvider);
  return service.watchActiveServices(uid);
});

final serviceFormProvider =
    StateNotifierProvider<ServiceFormNotifier, ServiceFormState>((ref) {
  return ServiceFormNotifier(ref);
});

class ServiceFormState {
  final String? serviceId;
  final String serviceName;
  final String category;
  final int price;
  final String estimatedDuration;
  final String description;
  final bool isActive;
  final bool isSubmitting;
  final String? errorMessage;

  const ServiceFormState({
    this.serviceId,
    this.serviceName = '',
    this.category = '',
    this.price = 0,
    this.estimatedDuration = '',
    this.description = '',
    this.isActive = true,
    this.isSubmitting = false,
    this.errorMessage,
  });

  ServiceFormState copyWith({
    String? serviceId,
    String? serviceName,
    String? category,
    int? price,
    String? estimatedDuration,
    String? description,
    bool? isActive,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return ServiceFormState(
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      category: category ?? this.category,
      price: price ?? this.price,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class ServiceFormNotifier extends StateNotifier<ServiceFormState> {
  final Ref ref;

  ServiceFormNotifier(this.ref) : super(const ServiceFormState());

  void loadService(ServiceModel service) {
    state = ServiceFormState(
      serviceId: service.serviceId,
      serviceName: service.serviceName,
      category: service.category,
      price: service.price,
      estimatedDuration: service.estimatedDuration,
      description: service.description ?? '',
      isActive: service.isActive,
    );
  }

  void reset() {
    state = const ServiceFormState();
  }

  void updateName(String value) => state = state.copyWith(serviceName: value);
  void updateCategory(String value) => state = state.copyWith(category: value);
  void updatePrice(int value) => state = state.copyWith(price: value);
  void updateDuration(String value) =>
      state = state.copyWith(estimatedDuration: value);
  void updateDescription(String value) =>
      state = state.copyWith(description: value);

  Future<bool> save() async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final uid = ref.read(currentUserIdProvider);
      if (uid == null) throw Exception('User tidak ditemukan');

      final service = ref.read(serviceCatalogServiceProvider);
      final now = DateTime.now();

      if (state.serviceId != null) {
        await service.updateService(uid, state.serviceId!, {
          'serviceName': state.serviceName,
          'category': state.category,
          'price': state.price,
          'estimatedDuration': state.estimatedDuration,
          'description': state.description.isEmpty ? null : state.description,
        });
      } else {
        final newService = ServiceModel(
          serviceId: '',
          serviceName: state.serviceName,
          category: state.category,
          price: state.price,
          estimatedDuration: state.estimatedDuration,
          description: state.description.isEmpty ? null : state.description,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );
        await service.createService(uid, newService);
      }

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> deactivate() async {
    if (state.serviceId == null) return;
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    await ref
        .read(serviceCatalogServiceProvider)
        .deactivateService(uid, state.serviceId!);
  }

  Future<void> delete() async {
    if (state.serviceId == null) return;
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    await ref
        .read(serviceCatalogServiceProvider)
        .deleteService(uid, state.serviceId!);
  }
}
