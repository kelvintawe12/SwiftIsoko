// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';

// class FirebaseConfig {
//   static Future<void> initialize() async {
//     // Only initialize if no default app exists
//     if (Firebase.apps.isEmpty) {
//       await Firebase.initializeApp(
//         options: _getFirebaseOptions(),
//       );
//       debugPrint('Firebase initialized');
//     } else {
//       debugPrint('Firebase already initialized');
//     }
//   }

//   static FirebaseOptions _getFirebaseOptions() {
//     if (defaultTargetPlatform == TargetPlatform.android) {
//       return const FirebaseOptions(
//         apiKey: 'YOUR_ANDROID_API_KEY',
//         appId: 'YOUR_ANDROID_APP_ID',
//         messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
//         projectId: 'YOUR_PROJECT_ID',
//         storageBucket: 'YOUR_STORAGE_BUCKET',
//       );
//     } else if (defaultTargetPlatform == TargetPlatform.iOS) {
//       return const FirebaseOptions(
//         apiKey: 'YOUR_IOS_API_KEY',
//         appId: 'YOUR_IOS_APP_ID',
//         messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
//         projectId: 'YOUR_PROJECT_ID',
//         storageBucket: 'YOUR_STORAGE_BUCKET',
//         iosBundleId: 'YOUR_IOS_BUNDLE_ID',
//       );
//     } else {
//       throw UnsupportedError('Platform not supported');
//     }
//   }
// }

// class CloudinaryConfig {
//   static const String cloudName = 'dfpxfdvli';
//   static const String uploadPreset = 'Bookswap flutter app';
// }
