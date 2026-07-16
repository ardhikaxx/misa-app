import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_paths.dart';
import '../models/business_model.dart';

class BusinessService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createBusiness(String uid, BusinessModel business) async {
    await _firestore.doc(FirestorePaths.businessDoc(uid)).set(business.toMap());
  }

  Future<BusinessModel?> getBusiness(String uid) async {
    final doc = await _firestore.doc(FirestorePaths.businessDoc(uid)).get();
    if (!doc.exists) return null;
    return BusinessModel.fromFirestore(doc);
  }

  Stream<BusinessModel?> watchBusiness(String uid) {
    return _firestore.doc(FirestorePaths.businessDoc(uid)).snapshots().map(
      (doc) => doc.exists ? BusinessModel.fromFirestore(doc) : null,
    );
  }

  Future<void> updateBusiness(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.doc(FirestorePaths.businessDoc(uid)).update(data);
  }

  Future<void> completeSetup(String uid) async {
    await _firestore.doc(FirestorePaths.businessDoc(uid)).update({
      'isSetupComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateLogo(String uid, String logoUrl) async {
    await _firestore.doc(FirestorePaths.businessDoc(uid)).update({
      'logoUrl': logoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
