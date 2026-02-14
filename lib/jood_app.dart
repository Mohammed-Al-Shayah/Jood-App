import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';
import 'core/theming/app_colors.dart';

class JoodApp extends StatelessWidget {
  final AppRouter appRouter;
  const JoodApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411, 917),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Jood',
          debugShowCheckedModeBanner: false,
          navigatorObservers: [routeObserver],
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Cairo',
            textTheme: Typography.material2021().black.apply(
              fontFamilyFallback: const ['Cairo'],
            ),
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.pageBackground,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.white,
            ),
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
            ),
          ),
          initialRoute: FirebaseAuth.instance.currentUser == null
              ? Routes.loginScreen
              : Routes.homeScreen,
          onGenerateRoute: appRouter.generateRoute,
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: widget ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
