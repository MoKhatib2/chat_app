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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDHr3npIhX6jvvHDdn7F3IgqjKpDoa0Yfw',
    appId: '1:818167339016:android:85bcb1ad1e4e7be26d59bd',
    messagingSenderId: '818167339016',
    projectId: 'flutter-prep-26684',
    databaseURL: 'https://flutter-prep-26684-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'flutter-prep-26684.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAELqBDfcwfAs1_AsO6M4M19O4bLJufkL0',
    appId: '1:818167339016:ios:1a2faff4eead1fa46d59bd',
    messagingSenderId: '818167339016',
    projectId: 'flutter-prep-26684',
    databaseURL: 'https://flutter-prep-26684-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'flutter-prep-26684.appspot.com',
    iosBundleId: 'com.example.chatApp',
  );

}