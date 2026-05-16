import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'core/localization/app_localization_controller.dart';
import 'core/routing/app_router.dart';
import 'core/theming/app_colors.dart';
import 'core/utils/app_strings.dart';
import 'core/widgets/app_keyboard_dismiss_region.dart';
import 'core/widgets/app_scroll_behavior.dart';
import 'features/auth/presentation/client_auth_gate.dart';

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
        return ValueListenableBuilder<Locale>(
          valueListenable: AppLocalizationController.instance.localeNotifier,
          builder: (context, locale, _) {
            return MaterialApp(
              title: AppStrings.appTitle,
              debugShowCheckedModeBanner: false,
              locale: locale,
              supportedLocales: AppLocalizationController.supportedLocales,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              localeResolutionCallback: (deviceLocale, supportedLocales) {
                return AppLocalizationController.instance
                    .resolveSupportedLocale(deviceLocale);
              },
              navigatorObservers: [routeObserver],
              scrollBehavior: const AppScrollBehavior(),
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
              home: const ClientAuthGate(),
              onGenerateRoute: appRouter.generateRoute,
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
      },
    );
  }
}
