import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/utils/extensions.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import '../logic/change_password_cubit.dart';
import '../logic/change_password_state.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChangePasswordCubit>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Change Password'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
        ),
        body: SafeArea(
          child: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
            listener: (context, state) {
              if (state.status == ChangePasswordStatus.failure &&
                  state.errorMessage != null) {
                showAppSnackBar(
                  context,
                  state.errorMessage!,
                  type: SnackBarType.error,
                );
              }
              if (state.status == ChangePasswordStatus.success) {
                showAppSnackBar(
                  context,
                  'Password changed successfully.',
                  type: SnackBarType.success,
                );
                context.pushNamedAndRemoveAll(Routes.loginScreen);
              }
            },
            builder: (context, state) {
              final isLoading = state.status == ChangePasswordStatus.loading;
              return Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter a new password for your account.',
                      style: AppTextStyles.cardMeta.copyWith(fontSize: 12.sp),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'New Password',
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      obscureText: !state.showPassword,
                      onChanged: context
                          .read<ChangePasswordCubit>()
                          .updatePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter new password',
                        suffixIcon: IconButton(
                          onPressed: context
                              .read<ChangePasswordCubit>()
                              .togglePasswordVisibility,
                          icon: Icon(
                            state.showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.textMuted,
                          ),
                        ),
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
                    SizedBox(height: 16.h),
                    Text(
                      'Confirm Password',
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      obscureText: !state.showConfirmPassword,
                      onChanged: context
                          .read<ChangePasswordCubit>()
                          .updateConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'Confirm password',
                        suffixIcon: IconButton(
                          onPressed: context
                              .read<ChangePasswordCubit>()
                              .toggleConfirmPasswordVisibility,
                          icon: Icon(
                            state.showConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.textMuted,
                          ),
                        ),
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
                    ElevatedButton(
                      onPressed: state.isValid && !isLoading
                          ? () => context.read<ChangePasswordCubit>().submit()
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
                              width: double.infinity,
                              child: Center(
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  'Change Password',
                                  style: AppTextStyles.cta,
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
