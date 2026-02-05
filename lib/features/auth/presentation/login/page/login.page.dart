import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:jood/core/constants/app_assets.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/utils/extensions.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
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
                showAppSnackBar(
                  context,
                  state.errorMessage!,
                  type: SnackBarType.error,
                );
              }
              if (state.status == LoginStatus.verificationLinkSent &&
                  state.errorMessage != null) {
                showAppSnackBar(context, state.errorMessage!);
              }
              if (state.status == LoginStatus.emailNotVerified &&
                  state.errorMessage != null) {
                _showEmailVerificationDialog(
                  context,
                  message: state.errorMessage!,
                );
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
                    Image.asset(AppAssets.logo, width: 100.w, height: 100.h),
                    SizedBox(height: 24.h),
                    _Label(
                      text: state.loginMethod == LoginMethod.phone
                          ? 'Phone Number'
                          : 'Email Address',
                    ),
                    if (state.loginMethod == LoginMethod.phone)
                      InternationalPhoneNumberInput(
                        initialValue: PhoneNumber(isoCode: state.phoneIso),
                        onInputChanged: (number) {
                          context.read<LoginCubit>().updateIdentifier(
                            number.phoneNumber ?? '',
                          );
                          final iso = number.isoCode;
                          if (iso != null && iso.isNotEmpty) {
                            context.read<LoginCubit>().updatePhoneIso(iso);
                          }
                        },
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                        ),
                        keyboardType: TextInputType.phone,
                        inputDecoration: InputDecoration(
                          hintText: 'Enter your phone number',
                          filled: true,
                          fillColor: const Color(0xFFF6F7FB),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      )
                    else
                      _TextField(
                        hintText: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: context.read<LoginCubit>().updateIdentifier,
                      ),
                    SizedBox(height: 5.h),
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
                    OutlinedButton.icon(
                      onPressed: () {
                        context.read<LoginCubit>().setLoginMethod(
                          state.loginMethod == LoginMethod.phone
                              ? LoginMethod.email
                              : LoginMethod.phone,
                        );
                      },
                      // icon: Icon(
                      //   state.loginMethod == LoginMethod.phone
                      //       ? Icons.alternate_email
                      //       : Icons.phone_android,
                      //   size: 18.sp,
                      //   color: AppColors.primary,
                      // ),
                      label: Text(
                        state.loginMethod == LoginMethod.phone
                            ? 'Login via email'
                            : 'Login via phone',
                        style: AppTextStyles.cardPrice.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary, width: 1.4),
                        backgroundColor: const Color(0xFFF7FFFD),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
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

Future<void> _showEmailVerificationDialog(
  BuildContext context, {
  required String message,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mark_email_unread_outlined,
                color: AppColors.primary,
                size: 30.sp,
              ),
              SizedBox(height: 10.h),
              Text('Verify your email', style: AppTextStyles.cardTitle),
              SizedBox(height: 8.h),
              Text(
                message,
                style: AppTextStyles.cardMeta,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.read<LoginCubit>().resendActivationLink();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: Text(
                    'Resend activation link',
                    style: AppTextStyles.body,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.read<LoginCubit>().switchToPhoneLogin();
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.textMuted),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: Text('Login with phone', style: AppTextStyles.body),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
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
