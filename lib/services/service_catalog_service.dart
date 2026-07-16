import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_paths.dart';
import '../models/service_model.dart';

class ServiceCatalogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ServiceModel>> watchServices(String uid) {
    return _firestore
        .collection(FirestorePaths.servicesCollection(uid))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<ServiceModel>> watchActiveServices(String uid) {
    return _firestore
        .collection(FirestorePaths.servicesCollection(uid))
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceModel.fromFirestore(doc))
            .toList());
  }

  Future<ServiceModel?> getService(String uid, String serviceId) async {
    final doc = await _firestore.doc(FirestorePaths.serviceDoc(uid, serviceId)).get();
    if (!doc.exists) return null;
    return ServiceModel.fromFirestore(doc);
  }

  Future<String> createService(String uid, ServiceModel service) async {
    final docRef = await _firestore
        .collection(FirestorePaths.servicesCollection(uid))
        .add(service.toMap());
    return docRef.id;
  }

  Future<void> updateService(String uid, String serviceId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.doc(FirestorePaths.serviceDoc(uid, serviceId)).update(data);
  }

  Future<void> deactivateService(String uid, String serviceId) async {
    await _firestore.doc(FirestorePaths.serviceDoc(uid, serviceId)).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteService(String uid, String serviceId) async {
    await _firestore.doc(FirestorePaths.serviceDoc(uid, serviceId)).delete();
  }
}
