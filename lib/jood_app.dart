import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';
import 'core/theming/colors_manager.dart';

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
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          theme: ThemeData(
            fontFamily: 'Cairo',
            textTheme: Typography.material2021().black.apply(
              fontFamilyFallback: const ['Cairo'],
            ),
            primaryColor: ColorsManager.mainBlue,
            scaffoldBackgroundColor: Colors.white,
          ),
          initialRoute: Routes.homeScreen,
          onGenerateRoute: appRouter.generateRoute,
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.noScaling,
              ),
              child: widget ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
