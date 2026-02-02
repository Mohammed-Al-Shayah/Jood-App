import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/utils/extensions.dart';
import 'package:jood/core/di/service_locator.dart';
import '../logic/login_cubit.dart';
import '../logic/login_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginCubit>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Log In', style: AppTextStyles.cardTitle),
          centerTitle: true,
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
        ),
        body: SafeArea(
          child: BlocConsumer<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state.status == LoginStatus.failure &&
                  state.errorMessage != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              }
              if (state.status == LoginStatus.success) {
                context.pushNamedAndRemoveAll(Routes.homeScreen);
              }
            },
            builder: (context, state) {
              final isLoading = state.status == LoginStatus.loading;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 12.h),
                    Image.asset(
                      'assets/images/logo1.png',
                      width: 100.w,
                      height: 100.h,
                    ),
                    SizedBox(height: 24.h),
                    _Label(text: 'Email or Phone'),
                    _TextField(
                      hintText: 'Enter your email or phone',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: context.read<LoginCubit>().updateEmail,
                    ),
                    SizedBox(height: 14.h),
                    _Label(text: 'Password'),
                    _TextField(
                      hintText: 'Enter your password',
                      obscureText: !state.showPassword,
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: context.read<LoginCubit>().updatePassword,
                      suffix: IconButton(
                        onPressed: context
                            .read<LoginCubit>()
                            .togglePasswordVisibility,
                        icon: Icon(
                          state.showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: state.rememberMe,
                              activeColor: AppColors.primary,
                              onChanged: (_) =>
                                  context.read<LoginCubit>().toggleRemember(),
                            ),
                            Text('Remember me', style: AppTextStyles.cardMeta),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            context.pushNamed(Routes.forgetPasswordScreen);
                          },
                          child: Text(
                            'Forgot password?',
                            style: AppTextStyles.body,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    ElevatedButton(
                      onPressed: state.isValid && !isLoading
                          ? () => context.read<LoginCubit>().submit()
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 18.h,
                              width: 18.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('Log In', style: AppTextStyles.cta),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Text('OR', style: AppTextStyles.cardMeta),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () => context.pushNamed(Routes.registerScreen),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.textPrimary),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: Text(
                        'Create a new account',
                        style: AppTextStyles.cardPrice.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.pushNamed(Routes.homeScreen),
                      child: Text(
                        'Continue as Guest',
                        style: AppTextStyles.cardPrice,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: AppTextStyles.sectionTitle.copyWith(fontSize: 14.sp),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.hintText,
    required this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
