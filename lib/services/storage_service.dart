import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadLogo(String uid, File file) async {
    final ext = p.extension(file.path);
    final ref = _storage.ref('businesses/$uid/logo/logo$ext');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<String> uploadQrisImage(String uid, File file) async {
    final ext = p.extension(file.path);
    final ref = _storage.ref('businesses/$uid/qris/qris$ext');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> deleteLogo(String uid) async {
    try {
      final ref = _storage.ref('businesses/$uid/logo');
      final result = await ref.listAll();
      for (final item in result.items) {
        await item.delete();
      }
    } catch (_) {}
  }

  Future<void> deleteQrisImage(String uid) async {
    try {
      final ref = _storage.ref('businesses/$uid/qris');
      final result = await ref.listAll();
      for (final item in result.items) {
        await item.delete();
      }
    } catch (_) {}
  }
}
