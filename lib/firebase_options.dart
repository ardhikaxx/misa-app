import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk platform ini',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCamTivo1L8BYHDNReBeke7O7ZZzDQDABg',
    appId: '1:970816764210:android:eec83e5c9f67914500ff2b',
    messagingSenderId: '970816764210',
    projectId: 'misa-6c18f',
    storageBucket: 'misa-6c18f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: '970816764210',
    projectId: 'misa-6c18f',
    storageBucket: 'misa-6c18f.firebasestorage.app',
    iosBundleId: 'com.example.misaApp',
  );
}
