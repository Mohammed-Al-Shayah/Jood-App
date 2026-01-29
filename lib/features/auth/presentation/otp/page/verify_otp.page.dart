import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/utils/extensions.dart';
import '../logic/otp_cubit.dart';
import '../logic/otp_state.dart';

class VerifyOtpPage extends StatelessWidget {
  const VerifyOtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OtpCubit>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Verify OTP'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
        ),
        body: SafeArea(
          child: BlocBuilder<OtpCubit, OtpState>(
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter the OTP sent to your email.',
                      style: AppTextStyles.cardMeta.copyWith(fontSize: 12.sp),
                    ),
                    SizedBox(height: 20.h),
                    TextField(
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      onChanged: context.read<OtpCubit>().updateCode,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '0000',
                        filled: true,
                        fillColor: const Color(0xFFF6F7FB),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: state.canResend
                              ? context.read<OtpCubit>().resend
                              : null,
                          child: Text(
                            'Resend',
                            style: TextStyle(
                              color: state.canResend
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '00:${state.secondsLeft.toString().padLeft(2, '0')}',
                          style: AppTextStyles.cardMeta.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.isValid
                              ? () => context.pushNamed(Routes.homeScreen)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                          ),
                          child: Text('Verify', style: AppTextStyles.cta),
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
