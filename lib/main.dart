import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/service_locator.dart';
import 'core/firebase/firebase_initializer.dart';
import 'core/firebase/firebase_messaging_service.dart';
import 'core/localization/app_localization_controller.dart';
import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';
import 'core/utils/seed_firestore.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/users/domain/usecases/sync_auth_user_usecase.dart';
import 'jood_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  EasyLoading.instance
    ..userInteractions = false
    ..maskType = EasyLoadingMaskType.black
    ..dismissOnTap = false;

  try {
    await initializeFirebase();
    if (kDebugMode) {
      try {
        await SeedFirestore.ensureSeeded();
      } catch (error, stackTrace) {
        debugPrint('SeedFirestore failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }

    // ThawaniConfig.validate();
    await ScreenUtil.ensureScreenSize();
    await AppLocalizationController.instance.initialize();
    await setupServiceLocator();

    final firebaseAuth = getIt<FirebaseAuth>();
    final authUser = await firebaseAuth.authStateChanges().first.timeout(
      const Duration(seconds: 2),
      onTimeout: () => firebaseAuth.currentUser,
    );
    final currentUser = authUser == null
        ? null
        : getIt<GetCurrentUserUseCase>()();
    if (currentUser != null) {
      await getIt<SyncAuthUserUseCase>()(currentUser);
    }

    runApp(
      JoodApp(
        appRouter: AppRouter(),
        initialRoute: currentUser == null
            ? Routes.loginScreen
            : Routes.homeScreen,
      ),
    );

    // Initialize FCM after the first frame to avoid blocking app startup.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseMessagingService().initialize();
    });
  } catch (error, stackTrace) {
    debugPrint('App bootstrap failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    runApp(_BootstrapErrorApp(error: error.toString()));
  }
}

class _BootstrapErrorApp extends StatelessWidget {
  const _BootstrapErrorApp({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'App Failed To Start',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'A startup error happened before the app could render.',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      SelectableText(
                        error,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFC62828),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
