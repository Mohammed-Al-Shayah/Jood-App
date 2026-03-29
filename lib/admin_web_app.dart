import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/routing/app_router.dart';
import 'core/theming/app_colors.dart';
import 'core/widgets/app_keyboard_dismiss_region.dart';
import 'core/widgets/app_scroll_behavior.dart';
import 'features/admin/presentation/web/admin_web_gate.dart';

class AdminWebApp extends StatelessWidget {
  const AdminWebApp({super.key, required this.appRouter});

  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1440, 1024),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Jood Admin',
          debugShowCheckedModeBanner: false,
          navigatorObservers: [routeObserver],
          scrollBehavior: const AppScrollBehavior(),
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Cairo',
            textTheme: Typography.material2021().black.apply(
              fontFamilyFallback: const ['Cairo'],
            ),
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: const Color(0xFFF5F7FB),
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
          onGenerateRoute: appRouter.generateRoute,
          home: const AdminWebGate(),
          builder: (context, widget) {
            final easyLoadingBuilder = EasyLoading.init();
            widget = easyLoadingBuilder(context, widget);
            final mediaQuery = MediaQuery.maybeOf(context);
            if (mediaQuery == null) {
              return AppKeyboardDismissRegion(child: widget);
            }
            return AppKeyboardDismissRegion(
              child: MediaQuery(
                data: mediaQuery.copyWith(textScaler: TextScaler.noScaling),
                child: widget,
              ),
            );
          },
        );
      },
    );
  }
}
