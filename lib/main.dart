import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/service_locator.dart';
import 'core/firebase/firebase_initializer.dart';
import 'core/routing/app_router.dart';
import 'core/utils/seed_firestore.dart';
import 'jood_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  if (!kReleaseMode) {
    await SeedFirestore.ensureSeeded();
  }
  await ScreenUtil.ensureScreenSize();
  await setupServiceLocator();
  runApp(
    JoodApp(appRouter: AppRouter()),
  );
}
