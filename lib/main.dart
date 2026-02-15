import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/di/service_locator.dart';
import 'core/firebase/firebase_initializer.dart';
import 'core/routing/app_router.dart';
import 'core/utils/seed_firestore.dart';
import 'features/users/domain/usecases/sync_auth_user_usecase.dart';
import 'jood_app.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  FlutterError.onError =
      FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  if (!kReleaseMode) {
    await SeedFirestore.ensureSeeded();
  }
  // ThawaniConfig.validate();
  await ScreenUtil.ensureScreenSize();
  await setupServiceLocator();
  final authUser = getIt<FirebaseAuth>().currentUser;
  if (authUser != null) {
    await getIt<SyncAuthUserUseCase>()(authUser);
  }
  runApp(JoodApp(appRouter: AppRouter()));
}
