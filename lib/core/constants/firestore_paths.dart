class FirestorePaths {
  FirestorePaths._();

  static String businessDoc(String uid) => 'businesses/$uid';
  static String servicesCollection(String uid) => 'businesses/$uid/services';
  static String serviceDoc(String uid, String serviceId) =>
      'businesses/$uid/services/$serviceId';
  static String customersCollection(String uid) => 'businesses/$uid/customers';
  static String customerDoc(String uid, String customerId) =>
      'businesses/$uid/customers/$customerId';
  static String transactionsCollection(String uid) =>
      'businesses/$uid/transactions';
  static String transactionDoc(String uid, String transactionId) =>
      'businesses/$uid/transactions/$transactionId';
  static String settingsDoc(String uid) => 'businesses/$uid/settings/general';
}
