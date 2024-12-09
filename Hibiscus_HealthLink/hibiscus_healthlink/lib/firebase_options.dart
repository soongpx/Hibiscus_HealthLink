// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDjugqW3308lVnEvba1JKT6ClIlRUNI-eY',
    appId: '1:57751856444:web:7a3ff26bc2560e7cc52a39',
    messagingSenderId: '57751856444',
    projectId: 'hibiscusdatabase',
    authDomain: 'hibiscusdatabase.firebaseapp.com',
    storageBucket: 'hibiscusdatabase.firebasestorage.app',
    measurementId: 'G-LZX6XPC3DL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB6aXnrj1N9dafBcuFDTMGTJkdrl6QJUVg',
    appId: '1:57751856444:android:f7e02135ac6fafb7c52a39',
    messagingSenderId: '57751856444',
    projectId: 'hibiscusdatabase',
    storageBucket: 'hibiscusdatabase.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBZMIVSGBeWGnAOh_7khpeTpnAg4vMKOM0',
    appId: '1:57751856444:ios:e71a3c926a521296c52a39',
    messagingSenderId: '57751856444',
    projectId: 'hibiscusdatabase',
    storageBucket: 'hibiscusdatabase.firebasestorage.app',
    iosBundleId: 'com.example.hibiscusHealthlink',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBZMIVSGBeWGnAOh_7khpeTpnAg4vMKOM0',
    appId: '1:57751856444:ios:e71a3c926a521296c52a39',
    messagingSenderId: '57751856444',
    projectId: 'hibiscusdatabase',
    storageBucket: 'hibiscusdatabase.firebasestorage.app',
    iosBundleId: 'com.example.hibiscusHealthlink',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDjugqW3308lVnEvba1JKT6ClIlRUNI-eY',
    appId: '1:57751856444:web:3a7f645e862155cfc52a39',
    messagingSenderId: '57751856444',
    projectId: 'hibiscusdatabase',
    authDomain: 'hibiscusdatabase.firebaseapp.com',
    storageBucket: 'hibiscusdatabase.firebasestorage.app',
    measurementId: 'G-313RNW9KZC',
  );
}
