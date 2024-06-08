//  Adarsh created this file


import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyC1lJItI11rTAwfe76c1ItjIdhkbNrU-hM",
      authDomain: "stotic-wallpaper-app.firebaseapp.com",
      projectId: "stotic-wallpaper-app",
      storageBucket: "stotic-wallpaper-app.appspot.com",
      messagingSenderId: "478372039637",
      appId: "1:478372039637:web:e74d4758da7c969f2e8b5c"
  );
}
