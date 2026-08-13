
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default FirebaseOptions for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Linux not configured for Firebase.',
        );
      default:
        throw UnsupportedError(
          'Unsupported platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDxCBxHCz-5oGksrst2HCaMAuMAB7s36Hk',
    appId: '1:377370391315:web:bac425e1d28d945b8b20e6',
    messagingSenderId: '377370391315',
    projectId: 'visionaptech-4893c',
    authDomain: 'visionaptech-4893c.firebaseapp.com',
    storageBucket: 'visionaptech-4893c.firebasestorage.app',
    measurementId: 'G-N0KDLXYJ61',
  );

  // 🌐 WEB CONFIG

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDzzsrPt0y1LwBN5-Atnbert0Wbwb-X4z0',
    appId: '1:377370391315:android:97d83512272c92d38b20e6',
    messagingSenderId: '377370391315',
    projectId: 'visionaptech-4893c',
    storageBucket: 'visionaptech-4893c.firebasestorage.app',
  );

  // 🤖 ANDROID

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD4NPqFVUBYyqVHFB3YXROSsNoOVyezBHg',
    appId: '1:377370391315:ios:4fa88e96b64b08748b20e6',
    messagingSenderId: '377370391315',
    projectId: 'visionaptech-4893c',
    storageBucket: 'visionaptech-4893c.firebasestorage.app',
    iosClientId: '377370391315-6rh67d1eiof9kf07v6ct3rqcqgo9o6p6.apps.googleusercontent.com',
    iosBundleId: 'com.example.myapp',
  );

  

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD4NPqFVUBYyqVHFB3YXROSsNoOVyezBHg',
    appId: '1:377370391315:ios:4fa88e96b64b08748b20e6',
    messagingSenderId: '377370391315',
    projectId: 'visionaptech-4893c',
    storageBucket: 'visionaptech-4893c.firebasestorage.app',
    iosClientId: '377370391315-6rh67d1eiof9kf07v6ct3rqcqgo9o6p6.apps.googleusercontent.com',
    iosBundleId: 'com.example.myapp',
  );

  // 🍎 macOS

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDxCBxHCz-5oGksrst2HCaMAuMAB7s36Hk',
    appId: '1:377370391315:web:47aa897acd2e41fb8b20e6',
    messagingSenderId: '377370391315',
    projectId: 'visionaptech-4893c',
    authDomain: 'visionaptech-4893c.firebaseapp.com',
    storageBucket: 'visionaptech-4893c.firebasestorage.app',
    measurementId: 'G-4C7QFB27MB',
  );

  // 🪟 WINDOWS
}