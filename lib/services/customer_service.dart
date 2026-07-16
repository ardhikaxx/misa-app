import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_paths.dart';
import '../models/customer_model.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CustomerModel>> watchCustomers(String uid) {
    return _firestore
        .collection(FirestorePaths.customersCollection(uid))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CustomerModel.fromFirestore(doc))
            .toList());
  }

  Future<CustomerModel?> getCustomer(String uid, String customerId) async {
    final doc = await _firestore.doc(FirestorePaths.customerDoc(uid, customerId)).get();
    if (!doc.exists) return null;
    return CustomerModel.fromFirestore(doc);
  }

  Future<String> createCustomer(String uid, CustomerModel customer) async {
    final docRef = await _firestore
        .collection(FirestorePaths.customersCollection(uid))
        .add(customer.toMap());
    return docRef.id;
  }

  Future<void> updateCustomer(String uid, String customerId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.doc(FirestorePaths.customerDoc(uid, customerId)).update(data);
  }

  Future<void> deleteCustomer(String uid, String customerId) async {
    await _firestore.doc(FirestorePaths.customerDoc(uid, customerId)).delete();
  }

  Future<void> incrementCustomerStats(String uid, String customerId, int amount) async {
    await _firestore.doc(FirestorePaths.customerDoc(uid, customerId)).update({
      'totalTransactions': FieldValue.increment(1),
      'totalSpent': FieldValue.increment(amount),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
