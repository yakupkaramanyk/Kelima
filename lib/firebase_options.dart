import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBUB-AYUxKrnJjQ08_x4BE7qMBOnGb5XjA',
    authDomain: 'kelima-7d07f.firebaseapp.com',
    projectId: 'kelima-7d07f',
    storageBucket: 'kelima-7d07f.firebasestorage.app',
    messagingSenderId: '350431073802',
    appId: '1:350431073802:web:93480b54d250e7337d71f3',
    measurementId: 'G-8NLG2WD1JD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBUB-AYUxKrnJjQ08_x4BE7qMBOnGb5XjA',
    authDomain: 'kelima-7d07f.firebaseapp.com',
    projectId: 'kelima-7d07f',
    storageBucket: 'kelima-7d07f.firebasestorage.app',
    messagingSenderId: '350431073802',
    appId: '1:350431073802:web:93480b54d250e7337d71f3',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBUB-AYUxKrnJjQ08_x4BE7qMBOnGb5XjA',
    authDomain: 'kelima-7d07f.firebaseapp.com',
    projectId: 'kelima-7d07f',
    storageBucket: 'kelima-7d07f.firebasestorage.app',
    messagingSenderId: '350431073802',
    appId: '1:350431073802:web:93480b54d250e7337d71f3',
  );
}
