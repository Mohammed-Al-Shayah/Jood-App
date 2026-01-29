import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/utils/extensions.dart';
import '../logic/register_cubit.dart';
import '../logic/register_state.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RegisterCubit>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Sign up'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
        ),
        body: SafeArea(
          child: BlocConsumer<RegisterCubit, RegisterState>(
            listener: (context, state) {
              if (state.status == RegisterStatus.failure &&
                  state.errorMessage != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              }
              if (state.status == RegisterStatus.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Verification email sent. Please verify.'),
                  ),
                );
                context.pushNamedAndRemoveAll(Routes.loginScreen);
              }
            },
            builder: (context, state) {
              final isLoading = state.status == RegisterStatus.loading;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label(text: 'Full Name'),
                    _Field(
                      hintText: 'Enter your full name',
                      onChanged: context.read<RegisterCubit>().updateFullName,
                    ),
                    _Label(text: 'Email Address'),
                    _Field(
                      hintText: 'Enter your email address',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: context.read<RegisterCubit>().updateEmail,
                    ),
                    _Label(text: 'Password'),
                    _Field(
                      hintText: 'Create a password',
                      obscureText: !state.showPassword,
                      onChanged: context.read<RegisterCubit>().updatePassword,
                      suffix: IconButton(
                        onPressed: context
                            .read<RegisterCubit>()
                            .togglePasswordVisibility,
                        icon: Icon(
                          state.showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    _Label(text: 'Confirm Password'),
                    _Field(
                      hintText: 'Confirm password',
                      obscureText: !state.showConfirmPassword,
                      onChanged: context
                          .read<RegisterCubit>()
                          .updateConfirmPassword,
                      suffix: IconButton(
                        onPressed: context
                            .read<RegisterCubit>()
                            .toggleConfirmPasswordVisibility,
                        icon: Icon(
                          state.showConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    _Label(text: 'Phone Number'),
                    _Field(
                      hintText: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
                      onChanged: context.read<RegisterCubit>().updatePhone,
                    ),
                    _Label(text: 'Country'),
                    _Field(
                      hintText: 'Select country',
                      onChanged: context.read<RegisterCubit>().updateCountry,
                    ),
                    _Label(text: 'City'),
                    _Field(
                      hintText: 'Enter your city',
                      onChanged: context.read<RegisterCubit>().updateCity,
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Checkbox(
                          value: state.termsAccepted,
                          activeColor: AppColors.primary,
                          onChanged: (_) =>
                              context.read<RegisterCubit>().toggleTerms(),
                        ),
                        Expanded(
                          child: Text(
                            'I agree to the Terms of Service and Privacy Policy',
                            style: AppTextStyles.cardMeta.copyWith(
                              fontSize: 12.sp,
                            ),
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
                              ? () => context.read<RegisterCubit>().submit()
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
                              : Text('Sign up', style: AppTextStyles.cta),
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

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h, bottom: 6.h),
      child: Text(
        text,
        style: AppTextStyles.sectionTitle.copyWith(fontSize: 14.sp),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
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
