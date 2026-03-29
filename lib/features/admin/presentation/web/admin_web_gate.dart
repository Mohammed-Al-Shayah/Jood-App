import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/errors/auth_error_mapper.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/features/admin/presentation/web/admin_web_shell_screen.dart';
import 'package:jood/features/auth/domain/usecases/login_with_email_usecase.dart';
import 'package:jood/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:jood/features/users/domain/entities/user_entity.dart';
import 'package:jood/features/users/domain/usecases/get_user_by_id_usecase.dart';

class AdminWebGate extends StatelessWidget {
  const AdminWebGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AdminWebLoadingScreen();
        }

        final authUser = snapshot.data;
        if (authUser == null) {
          return const AdminWebLoginScreen();
        }

        return FutureBuilder<UserEntity?>(
          future: getIt<GetUserByIdUseCase>()(authUser.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const _AdminWebLoadingScreen();
            }

            final profile = userSnapshot.data;
            if (profile == null) {
              return const _AdminAccessDeniedScreen(
                title: 'Admin profile not found',
                message:
                    'This account does not have an admin profile in the current project.',
              );
            }

            if (!_isAdminRole(profile.role)) {
              return _AdminAccessDeniedScreen(
                title: 'Access denied',
                message:
                    'Your current role "${profile.role}" does not have access to the admin dashboard.',
              );
            }

            return AdminWebShellScreen(currentUser: profile);
          },
        );
      },
    );
  }
}

bool _isAdminRole(String role) {
  return role.trim().toLowerCase() == 'admin';
}

class AdminWebLoginScreen extends StatefulWidget {
  const AdminWebLoginScreen({super.key});

  @override
  State<AdminWebLoginScreen> createState() => _AdminWebLoginScreenState();
}

class _AdminWebLoginScreenState extends State<AdminWebLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await getIt<LoginWithEmailUseCase>()(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Authentication did not return a valid user.',
        );
      }

      final profile = await getIt<GetUserByIdUseCase>()(user.uid);
      if (profile == null || !_isAdminRole(profile.role)) {
        await getIt<SignOutUseCase>()();
        setState(() {
          _errorMessage = profile == null
              ? 'No admin profile found for this account.'
              : 'This account is not allowed to access the admin dashboard.';
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = mapFirebaseAuthException(
          e,
          fallbackMessage: 'Unable to sign in. Please try again.',
        );
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final stacked = width < 980;
            final pagePadding = width < 720 ? 16.0 : 24.0;
            final panelGap = width < 720 ? 16.0 : 24.0;
            final promoPadding = width < 720 ? 24.0 : 32.0;
            final formWidth = width >= 1280 ? 420.0 : 400.0;
            final maxContentWidth = math.min(width, 1120.0);
            final horizontalPadding = pagePadding * 2;
            final contentWidth = math.max(
              0.0,
              maxContentWidth - horizontalPadding,
            );
            final promoWidth = math.max(
              0.0,
              contentWidth - formWidth - panelGap,
            );

            final promoPanel = Container(
              padding: EdgeInsets.all(promoPadding),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F8C85), Color(0xFF105BC8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: width < 720 ? 60.0 : 68.0,
                    height: width < 720 ? 60.0 : 68.0,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: Icon(
                      Icons.dashboard_customize_outlined,
                      size: width < 720 ? 30.0 : 34.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Jood Admin Dashboard',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: Colors.white,
                      fontSize: width < 720 ? 26.0 : 30.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Manage restaurants, offers, bookings, and users from a dedicated Flutter Web control panel.',
                    style: AppTextStyles.cardMeta.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: width < 720 ? 14.0 : 15.0,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  const _FeaturePoint(text: 'Desktop-first responsive layout'),
                  const _FeaturePoint(
                    text: 'Shared data layer with the existing Jood app',
                  ),
                  const _FeaturePoint(
                    text: 'Admin-only access using the current auth stack',
                  ),
                ],
              ),
            );

            final formCard = Container(
              width: stacked ? double.infinity : formWidth,
              padding: EdgeInsets.all(width < 720 ? 22.0 : 28.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 30.r,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign in',
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: width < 720 ? 24.0 : 28.0,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Use your admin email and password to continue.',
                      style: AppTextStyles.cardMeta.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    const _WebFieldLabel(text: 'Email'),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _adminWebInputDecoration(
                        hintText: 'admin@jood.com',
                      ),
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) {
                          return 'Email is required.';
                        }
                        if (!text.contains('@')) {
                          return 'Enter a valid email.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    const _WebFieldLabel(text: 'Password'),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _adminWebInputDecoration(
                        hintText: 'Enter your password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? '').isEmpty) {
                          return 'Password is required.';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (_errorMessage != null) ...[
                      SizedBox(height: 14.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F0),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: AppTextStyles.cardMeta.copyWith(
                            color: const Color(0xFFC62828),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 22.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text('Open dashboard', style: AppTextStyles.cta),
                      ),
                    ),
                  ],
                ),
              ),
            );

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(pagePadding),
                  child: stacked
                      ? Column(
                          children: [
                            promoPanel,
                            SizedBox(height: panelGap),
                            formCard,
                          ],
                        )
                      : SizedBox(
                          width: contentWidth,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: promoWidth, child: promoPanel),
                              SizedBox(width: panelGap),
                              SizedBox(width: formWidth, child: formCard),
                            ],
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AdminWebLoadingScreen extends StatelessWidget {
  const _AdminWebLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF4F7FB),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _AdminAccessDeniedScreen extends StatelessWidget {
  const _AdminAccessDeniedScreen({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(28.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 24.r,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4E5),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        size: 30.sp,
                        color: const Color(0xFFB26A00),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(title, style: AppTextStyles.cardTitle),
                    SizedBox(height: 10.h),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.cardMeta.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    OutlinedButton.icon(
                      onPressed: () => getIt<SignOutUseCase>()(),
                      icon: const Icon(Icons.logout_outlined),
                      label: const Text('Use another account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturePoint extends StatelessWidget {
  const _FeaturePoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.white, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.cardMeta.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebFieldLabel extends StatelessWidget {
  const _WebFieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: AppTextStyles.sectionTitle.copyWith(fontSize: 14.sp),
      ),
    );
  }
}

InputDecoration _adminWebInputDecoration({
  required String hintText,
  Widget? suffixIcon,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16.r),
    borderSide: BorderSide.none,
  );

  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: const Color(0xFFF6F7FB),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    border: border,
    enabledBorder: border,
    focusedBorder: border,
    suffixIcon: suffixIcon,
  );
}
