import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import 'firebase_messaging_service.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // تعطيل التحقق (reCAPTCHA/APNs) للتطوير - يحل internal-error على iOS
  if (kDebugMode) {
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
    );
  }

  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
  //   appleProvider: kReleaseMode ? AppleProvider.appAttest : AppleProvider.debug,
  // );

  const useDebugAppCheck = false;

  await FirebaseAppCheck.instance.activate(
    androidProvider: (kReleaseMode && !useDebugAppCheck)
        // ignore: dead_code
        ? AndroidProvider.playIntegrity
        : AndroidProvider.debug,
    appleProvider: (kReleaseMode && !useDebugAppCheck)
        // ignore: dead_code
        ? AppleProvider.appAttest
        : AppleProvider.debug,
  );

  // تسجيل معالج الرسائل في الخلفية (مطلوب قبل runApp)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}
