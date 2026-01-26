import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/service_locator.dart';
import 'core/firebase/firebase_initializer.dart';
import 'core/routing/app_router.dart';
import 'jood_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await initializeFirebase();
  await ScreenUtil.ensureScreenSize();
  await setupServiceLocator();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: JoodApp(appRouter: AppRouter()),
    ),
  );
}
