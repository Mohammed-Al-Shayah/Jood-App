import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';


Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  const useDebugAppCheck = false; 

  await FirebaseAppCheck.instance.activate(
    androidProvider:
        (kReleaseMode && !useDebugAppCheck)
            ? AndroidProvider.playIntegrity
            : AndroidProvider.debug,
    appleProvider:
        (kReleaseMode && !useDebugAppCheck)
            ? AppleProvider.appAttest
            : AppleProvider.debug,
  );
}
