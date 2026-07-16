import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Terjadi kesalahan autentikasi']);
}

class FirestoreFailure extends Failure {
  const FirestoreFailure([super.message = 'Terjadi kesalahan database']);
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Terjadi kesalahan penyimpanan']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Tidak ada koneksi internet']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Terjadi kesalahan yang tidak diketahui']);
}
