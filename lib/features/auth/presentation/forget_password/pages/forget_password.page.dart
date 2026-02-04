import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/utils/extensions.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import '../../otp/verify_otp_args.dart';
import '../logic/forget_password_cubit.dart';
import '../logic/forget_password_state.dart';

class ForgetPasswordPage extends StatelessWidget {
  const ForgetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ForgetPasswordCubit>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Forget Password'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
        ),
        body: SafeArea(
          child: BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
            listener: (context, state) {
              if (state.status == ForgetPasswordStatus.failure &&
                  state.errorMessage != null) {
                showAppSnackBar(
                  context,
                  state.errorMessage!,
                  type: SnackBarType.error,
                );
              }
              if (state.status == ForgetPasswordStatus.success) {
                showAppSnackBar(
                  context,
                  'Reset email sent. Please check your inbox.',
                  type: SnackBarType.success,
                );
                context.pushNamed(Routes.loginScreen);
              }
              if (state.status == ForgetPasswordStatus.phoneOtpSent &&
                  state.verificationId != null) {
                context.pushNamed(
                  Routes.verifyOtpScreen,
                  arguments: VerifyOtpArgs.resetPassword(
                    verificationId: state.verificationId!,
                    phone: state.input.trim(),
                    resendToken: state.resendToken,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state.status == ForgetPasswordStatus.loading;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter your email to receive a reset link, or enter your phone to verify with OTP and set a new password.',
                      style: AppTextStyles.cardMeta.copyWith(fontSize: 12.sp),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Email or Phone',
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      onChanged: context
                          .read<ForgetPasswordCubit>()
                          .updateIdentifier,
                      decoration: InputDecoration(
                        hintText: 'Enter your email or phone',
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
                    ),
                    SizedBox(height: 24.h),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.isValid && !isLoading
                              ? () =>
                                    context.read<ForgetPasswordCubit>().submit()
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
                              : Text('Verify', style: AppTextStyles.cta),
                        ),
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
