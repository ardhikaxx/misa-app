sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class FirestoreException extends AppException {
  const FirestoreException(super.message);
}

class StorageException extends AppException {
  const StorageException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}
