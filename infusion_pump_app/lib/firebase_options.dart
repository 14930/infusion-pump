import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration options.
///
/// HOW TO SET UP:
/// 1. Go to https://console.firebase.google.com
/// 2. Create a new project (or use existing)
/// 3. Add an Android app with package name: com.infusionpump.infusion_pump_app
/// 4. Download google-services.json and place it in android/app/
/// 5. Add an iOS app (if needed) and download GoogleService-Info.plist
/// 6. Replace the placeholder values below with your actual Firebase config
///
/// ALTERNATIVE: Use FlutterFire CLI:
///   dart pub global activate flutterfire_cli
///   flutterfire configure
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
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA4ZIxMaRqzXCDJwdez8pOXCySrjSLWz5U',
    appId: '1:92975288388:android:d3632e0628e7344c6e2c11',
    messagingSenderId: '92975288388',
    projectId: 'infusion-pump-fl',
    databaseURL: 'https://infusion-pump-fl-default-rtdb.firebaseio.com',
    storageBucket: 'infusion-pump-fl.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB494glUf-wTggvQqm6hNX1RI72ssybIzE',
    appId: '1:92975288388:ios:366147c0a10708a96e2c11',
    messagingSenderId: '92975288388',
    projectId: 'infusion-pump-fl',
    databaseURL: 'https://infusion-pump-fl-default-rtdb.firebaseio.com',
    storageBucket: 'infusion-pump-fl.firebasestorage.app',
    iosBundleId: 'com.infusionpump.infusionPumpApp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCdOSqFwpb2ZPEJdLxHVSUQmhjq3n8F5kc',
    appId: '1:92975288388:web:0e0ab26c53e6b7c36e2c11',
    messagingSenderId: '92975288388',
    projectId: 'infusion-pump-fl',
    authDomain: 'infusion-pump-fl.firebaseapp.com',
    databaseURL: 'https://infusion-pump-fl-default-rtdb.firebaseio.com',
    storageBucket: 'infusion-pump-fl.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB494glUf-wTggvQqm6hNX1RI72ssybIzE',
    appId: '1:92975288388:ios:366147c0a10708a96e2c11',
    messagingSenderId: '92975288388',
    projectId: 'infusion-pump-fl',
    databaseURL: 'https://infusion-pump-fl-default-rtdb.firebaseio.com',
    storageBucket: 'infusion-pump-fl.firebasestorage.app',
    iosBundleId: 'com.infusionpump.infusionPumpApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCdOSqFwpb2ZPEJdLxHVSUQmhjq3n8F5kc',
    appId: '1:92975288388:web:e783ab4c0a842c986e2c11',
    messagingSenderId: '92975288388',
    projectId: 'infusion-pump-fl',
    authDomain: 'infusion-pump-fl.firebaseapp.com',
    databaseURL: 'https://infusion-pump-fl-default-rtdb.firebaseio.com',
    storageBucket: 'infusion-pump-fl.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyCdOSqFwpb2ZPEJdLxHVSUQmhjq3n8F5kc',
    appId: '1:92975288388:web:0e0ab26c53e6b7c36e2c11',
    messagingSenderId: '92975288388',
    projectId: 'infusion-pump-fl',
    authDomain: 'infusion-pump-fl.firebaseapp.com',
    databaseURL: 'https://infusion-pump-fl-default-rtdb.firebaseio.com',
    storageBucket: 'infusion-pump-fl.firebasestorage.app',
  );
}