import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'admin_web_app.dart';
import 'core/di/service_locator.dart';
import 'core/firebase/firebase_initializer.dart';
import 'core/utils/seed_firestore.dart';
import 'features/users/domain/usecases/sync_auth_user_usecase.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EasyLoading.instance
    ..userInteractions = false
    ..maskType = EasyLoadingMaskType.black
    ..dismissOnTap = false;

  try {
    await initializeFirebase();
    if (!kReleaseMode && !kIsWeb) {
      await SeedFirestore.ensureSeeded();
    }
    await ScreenUtil.ensureScreenSize();
    await setupServiceLocator();

    final authUser = getIt<FirebaseAuth>().currentUser;
    if (authUser != null) {
      await getIt<SyncAuthUserUseCase>()(authUser);
    }

    runApp(AdminWebApp(appRouter: AppRouter()));
  } catch (error, stackTrace) {
    debugPrint('Admin web bootstrap failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    runApp(_AdminWebBootstrapErrorApp(error: error.toString()));
  }
}

class _AdminWebBootstrapErrorApp extends StatelessWidget {
  const _AdminWebBootstrapErrorApp({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                        'Admin Web Failed To Start',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'A startup error happened before the dashboard could render.',
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
