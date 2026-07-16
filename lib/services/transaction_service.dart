import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_paths.dart';
import '../models/transaction_model.dart';
import '../core/utils/invoice_number_generator.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TransactionModel>> watchTransactions(String uid) {
    return _firestore
        .collection(FirestorePaths.transactionsCollection(uid))
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<TransactionModel>> watchTransactionsByStatus(String uid, String paymentStatus) {
    return _firestore
        .collection(FirestorePaths.transactionsCollection(uid))
        .where('paymentStatus', isEqualTo: paymentStatus)
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<TransactionModel>> watchTransactionsByJobStatus(String uid, String jobStatus) {
    return _firestore
        .collection(FirestorePaths.transactionsCollection(uid))
        .where('jobStatus', isEqualTo: jobStatus)
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<TransactionModel>> watchTransactionsByDateRange(
    String uid,
    DateTime start,
    DateTime end,
  ) {
    return _firestore
        .collection(FirestorePaths.transactionsCollection(uid))
        .where('transactionDate', isGreaterThanOrEqualTo: start)
        .where('transactionDate', isLessThan: end)
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }

  Future<TransactionModel?> getTransaction(String uid, String transactionId) async {
    final doc = await _firestore.doc(FirestorePaths.transactionDoc(uid, transactionId)).get();
    if (!doc.exists) return null;
    return TransactionModel.fromFirestore(doc);
  }

  Future<String> generateInvoiceNumber(String uid, String businessName) async {
    final settingsRef = _firestore.doc(FirestorePaths.settingsDoc(uid));

    return await _firestore.runTransaction((transaction) async {
      final settingsDoc = await transaction.get(settingsRef);
      int counter = 1;
      String prefix = 'INV';

      if (settingsDoc.exists) {
        final data = settingsDoc.data()!;
        counter = (data['invoiceSequenceCounter'] ?? 0) + 1;
        prefix = data['invoicePrefix'] ?? 'INV';

        transaction.update(settingsRef, {
          'invoiceSequenceCounter': counter,
        });
      } else {
        transaction.set(settingsRef, {
          'invoicePrefix': 'INV',
          'invoiceSequenceCounter': 1,
          'invoiceFooterNote': 'Terima kasih telah menggunakan jasa kami',
          'defaultPaymentMethod': 'cash',
          'currencyFormat': 'IDR',
          'resetCounterMonthly': false,
        });
        counter = 1;
      }

      final number = InvoiceNumberGenerator.generate(
        businessName: businessName,
        date: DateTime.now(),
        sequence: counter,
        prefix: prefix,
      );

      return number;
    });
  }

  Future<String> createTransaction(String uid, TransactionModel transaction) async {
    final docRef = await _firestore
        .collection(FirestorePaths.transactionsCollection(uid))
        .add(transaction.toMap());
    return docRef.id;
  }

  Future<void> updateTransaction(String uid, String transactionId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.doc(FirestorePaths.transactionDoc(uid, transactionId)).update(data);
  }

  Future<void> updateJobStatus(String uid, String transactionId, String jobStatus) async {
    await _firestore.doc(FirestorePaths.transactionDoc(uid, transactionId)).update({
      'jobStatus': jobStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePaymentStatus(
    String uid,
    String transactionId,
    String paymentStatus,
    int amountPaid,
  ) async {
    final updates = <String, dynamic>{
      'paymentStatus': paymentStatus,
      'amountPaid': amountPaid,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _firestore.doc(FirestorePaths.transactionDoc(uid, transactionId)).update(updates);
  }

  Future<void> markInvoiceGenerated(String uid, String transactionId) async {
    await _firestore.doc(FirestorePaths.transactionDoc(uid, transactionId)).update({
      'invoiceGeneratedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTransaction(String uid, String transactionId) async {
    await _firestore.doc(FirestorePaths.transactionDoc(uid, transactionId)).delete();
  }

  Stream<Map<String, dynamic>?> watchSettings(String uid) {
    return _firestore
        .doc(FirestorePaths.settingsDoc(uid))
        .snapshots()
        .map((snapshot) => snapshot.exists ? snapshot.data() : null);
  }

  Future<Map<String, dynamic>?> getSettings(String uid) async {
    final doc = await _firestore.doc(FirestorePaths.settingsDoc(uid)).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  Future<void> updateSettings(String uid, Map<String, dynamic> data) async {
    await _firestore.doc(FirestorePaths.settingsDoc(uid)).update(data);
  }

  Future<List<TransactionModel>> getTransactionsByDateRangeSync(
    String uid,
    DateTime start,
    DateTime end,
  ) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.transactionsCollection(uid))
        .where('transactionDate', isGreaterThanOrEqualTo: start)
        .where('transactionDate', isLessThan: end)
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();
  }

  /// Ambil semua transaksi yang belum lunas (unpaid + partial) untuk dashboard piutang
  Future<List<TransactionModel>> getUnpaidTransactions(String uid) async {
    final unpaid = await _firestore
        .collection(FirestorePaths.transactionsCollection(uid))
        .where('paymentStatus', whereIn: ['unpaid', 'partial'])
        .get();

    return unpaid.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();
  }

  /// Duplikasi transaksi: buat transaksi baru berdasarkan data transaksi yang ada
  Future<String> duplicateTransaction(
    String uid,
    TransactionModel source,
    String newInvoiceNumber,
  ) async {
    final now = DateTime.now();
    final duplicate = TransactionModel(
      transactionId: '',
      invoiceNumber: newInvoiceNumber,
      transactionDate: now,
      customerId: source.customerId,
      customerSnapshot: source.customerSnapshot,
      items: source.items,
      subtotal: source.subtotal,
      discountAmount: source.discountAmount,
      discountNote: source.discountNote,
      additionalFee: source.additionalFee,
      additionalFeeNote: source.additionalFeeNote,
      totalAmount: source.totalAmount,
      paymentMethod: source.paymentMethod,
      paymentStatus: 'unpaid', // selalu mulai dari unpaid
      amountPaid: 0,
      jobStatus: 'waiting', // selalu mulai dari waiting
      notes: source.notes,
      createdAt: now,
      updatedAt: now,
    );
    return createTransaction(uid, duplicate);
  }
}
