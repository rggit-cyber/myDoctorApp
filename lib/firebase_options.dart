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
    apiKey: 'AIzaSyAyqqnxKUuPT7PCmPKOfr4SRyT9_PVMOZ8',
    appId: '1:101138540925:web:f37f610d5563fbddf2c414',
    messagingSenderId: '101138540925',
    projectId: 'doctorapp-5c57e',
    authDomain: 'doctorapp-5c57e.firebaseapp.com',
    storageBucket: 'doctorapp-5c57e.firebasestorage.app',
    measurementId: 'G-3CYHH86NZX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBUkMZ3aW0WOoCGabQ0SUEvwESstzsXTOU',
    appId: '1:101138540925:android:3fb1ceae3dcc5924f2c414',
    messagingSenderId: '101138540925',
    projectId: 'doctorapp-5c57e',
    storageBucket: 'doctorapp-5c57e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDOLlzQcp8UD7clE9f-J5bVj0jYIY95KWM',
    appId: '1:101138540925:ios:9a20691af07b9697f2c414',
    messagingSenderId: '101138540925',
    projectId: 'doctorapp-5c57e',
    storageBucket: 'doctorapp-5c57e.firebasestorage.app',
    iosBundleId: 'com.robogalactic.doctorApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDOLlzQcp8UD7clE9f-J5bVj0jYIY95KWM',
    appId: '1:101138540925:ios:9a20691af07b9697f2c414',
    messagingSenderId: '101138540925',
    projectId: 'doctorapp-5c57e',
    storageBucket: 'doctorapp-5c57e.firebasestorage.app',
    iosBundleId: 'com.robogalactic.doctorApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAyqqnxKUuPT7PCmPKOfr4SRyT9_PVMOZ8',
    appId: '1:101138540925:web:53535074aabb0d7df2c414',
    messagingSenderId: '101138540925',
    projectId: 'doctorapp-5c57e',
    authDomain: 'doctorapp-5c57e.firebaseapp.com',
    storageBucket: 'doctorapp-5c57e.firebasestorage.app',
    measurementId: 'G-HYLKFFV3JF',
  );
}
