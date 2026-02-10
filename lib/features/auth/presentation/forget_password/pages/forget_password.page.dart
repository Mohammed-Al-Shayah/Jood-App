import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
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
                      state.method == ForgetPasswordMethod.email
                          ? 'Enter your email to receive a reset link.'
                          : 'Enter your phone to verify with OTP and set a new password.',
                      style: AppTextStyles.cardMeta.copyWith(fontSize: 12.sp),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      state.method == ForgetPasswordMethod.phone
                          ? 'Phone Number'
                          : 'Email Address',
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (state.method == ForgetPasswordMethod.phone)
                      InternationalPhoneNumberInput(
                        initialValue: PhoneNumber(isoCode: state.phoneIso),
                        onInputChanged: (number) {
                          context.read<ForgetPasswordCubit>().updateIdentifier(
                            number.phoneNumber ?? '',
                          );
                          final iso = number.isoCode;
                          if (iso != null && iso.isNotEmpty) {
                            context.read<ForgetPasswordCubit>().updatePhoneIso(
                              iso,
                            );
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
                      TextField(
                        keyboardType: TextInputType.emailAddress,
                        onChanged: context
                            .read<ForgetPasswordCubit>()
                            .updateIdentifier,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
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
                              : Text(
                                  state.method == ForgetPasswordMethod.phone
                                      ? 'Verify'
                                      : 'Send reset link',
                                  style: AppTextStyles.cta,
                                ),
                        ),
                      ),
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
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                context.read<ForgetPasswordCubit>().setMethod(
                                  state.method == ForgetPasswordMethod.phone
                                      ? ForgetPasswordMethod.email
                                      : ForgetPasswordMethod.phone,
                                );
                              },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.primary,
                            width: 1.6,
                          ),
                          backgroundColor: const Color(0xFFF7FFFD),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                        child: Text(
                          state.method == ForgetPasswordMethod.phone
                              ? 'Use email instead'
                              : 'Use phone instead',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.cardTitle.copyWith(
                            color: AppColors.primary,
                            // fontWeight: FontWeight.w700,
                          ),
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
