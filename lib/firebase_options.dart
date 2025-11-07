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
    apiKey: 'AIzaSyBheEU2eWSkiPAG8Pm0WF_NNBOqRgmpGNo',
    appId: '1:208763508079:android:c3c6fdb095ce4dbcadc49a',
    messagingSenderId: '208763508079',
    projectId: 'copilot-trip-wizards',
    storageBucket: 'copilot-trip-wizards.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'trip-wizards-app',
    storageBucket: 'trip-wizards-app.appspot.com',
    iosBundleId: 'com.tripwizards.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDUmsWGJTKvJjSA23du5BmQYbzr9jBoy2g',
    appId: '1:208763508079:web:3aaee8cb48d88372adc49a',
    messagingSenderId: '208763508079',
    projectId: 'copilot-trip-wizards',
    authDomain: 'copilot-trip-wizards.firebaseapp.com',
    storageBucket: 'copilot-trip-wizards.firebasestorage.app',
    measurementId: 'G-KEE8GMMH88',
  );

}