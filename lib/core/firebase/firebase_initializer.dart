import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import 'firebase_messaging_service.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Web admin only needs the base Firebase app during bootstrap.
  // App Check, auth test settings, and background messaging are configured
  // only for mobile targets to avoid web startup crashes.
  if (kIsWeb) {
    return;
  }

  if (kDebugMode) {
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
    );
  }

  const useDebugAppCheck = false;

  await FirebaseAppCheck.instance.activate(
    androidProvider: (kReleaseMode && !useDebugAppCheck)
        ? AndroidProvider.playIntegrity
        : AndroidProvider.debug,
    appleProvider: (kReleaseMode && !useDebugAppCheck)
        ? AppleProvider.appAttest
        : AppleProvider.debug,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}
