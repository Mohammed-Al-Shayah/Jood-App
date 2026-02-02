import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/utils/extensions.dart';
import '../../../../users/domain/usecases/create_user_usecase.dart';
import '../logic/otp_cubit.dart';
import '../logic/otp_state.dart';
import '../verify_otp_args.dart';

class VerifyOtpPage extends StatelessWidget {
  const VerifyOtpPage({super.key, required this.args});

  final VerifyOtpArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpCubit(
        auth: getIt(),
        createUser: getIt<CreateUserUseCase>(),
        args: args,
      ),
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
          child: BlocConsumer<OtpCubit, OtpState>(
            listener: (context, state) {
              if (state.status == OtpStatus.failure &&
                  state.errorMessage != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              }
              if (state.status == OtpStatus.success) {
                context.pushNamedAndRemoveAll(Routes.homeScreen);
              }
            },
            builder: (context, state) {
              final isLoading = state.status == OtpStatus.verifying;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter the OTP sent to your phone (${args.phone}).',
                      style: AppTextStyles.cardMeta.copyWith(fontSize: 12.sp),
                    ),
                    SizedBox(height: 20.h),
                    TextField(
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      onChanged: context.read<OtpCubit>().updateCode,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '000000',
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
                          onPressed: state.isValid && !isLoading
                              ? () => context.read<OtpCubit>().verify()
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
