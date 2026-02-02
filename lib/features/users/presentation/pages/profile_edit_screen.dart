import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import '../../domain/entities/user_entity.dart';
import '../cubit/profile_edit_cubit.dart';
import '../cubit/profile_edit_state.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key, required this.user});

  final UserEntity user;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  bool _otpSheetOpen = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileEditCubit(
        updateUser: getIt(),
        getUserByPhone: getIt(),
        auth: getIt(),
        user: widget.user,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Edit profile'),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: SafeArea(
          child: BlocConsumer<ProfileEditCubit, ProfileEditState>(
            listener: (context, state) {
              if (state.status == ProfileEditStatus.success) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  if (_otpSheetOpen && Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                    _otpSheetOpen = false;
                  }
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop(true);
                  }
                });
              }
              if (state.status == ProfileEditStatus.failure &&
                  state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage!)),
                );
              }
              if (state.status == ProfileEditStatus.otpSent && !_otpSheetOpen) {
                final cubit = context.read<ProfileEditCubit>();
                _otpSheetOpen = true;
                _showOtpSheet(context, cubit).whenComplete(() {
                  if (mounted) {
                    setState(() {
                      _otpSheetOpen = false;
                    });
                  }
                });
              }
            },
            builder: (context, state) {
              final isSaving = state.status == ProfileEditStatus.saving ||
                  state.status == ProfileEditStatus.otpSending ||
                  state.status == ProfileEditStatus.otpVerifying;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label(text: 'Full name'),
                    _Field(
                      initialValue: state.fullName,
                      onChanged: context.read<ProfileEditCubit>().updateFullName,
                    ),
                    _Label(text: 'Email'),
                    _Field(
                      initialValue: state.email,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: context.read<ProfileEditCubit>().updateEmail,
                    ),
                    _Label(text: 'Phone'),
                    InternationalPhoneNumberInput(
                      initialValue: PhoneNumber(
                        isoCode: state.phoneIso,
                        phoneNumber: state.phone,
                      ),
                      onInputChanged: (number) {
                        context.read<ProfileEditCubit>().updatePhone(
                          number.phoneNumber ?? '',
                        );
                        final iso = number.isoCode;
                        if (iso != null && iso.isNotEmpty) {
                          context.read<ProfileEditCubit>().updatePhoneIso(iso);
                        }
                      },
                      selectorConfig: const SelectorConfig(
                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                      ),
                      keyboardType: TextInputType.phone,
                      inputDecoration: InputDecoration(
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
                    _Label(text: 'Country'),
                    _Field(
                      initialValue: state.country,
                      onChanged: context.read<ProfileEditCubit>().updateCountry,
                    ),
                    _Label(text: 'City'),
                    _Field(
                      initialValue: state.city,
                      onChanged: context.read<ProfileEditCubit>().updateCity,
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () => context.read<ProfileEditCubit>().save(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                          child: isSaving
                              ? SizedBox(
                                  height: 18.h,
                                  width: 18.h,
                                  child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text('Save', style: AppTextStyles.cta),
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

Future<void> _showOtpSheet(BuildContext context, ProfileEditCubit cubit) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (_) {
      return BlocProvider.value(
        value: cubit,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20.w,
            12.h,
            20.w,
            MediaQuery.of(context).viewInsets.bottom + 20.h,
          ),
          child: BlocBuilder<ProfileEditCubit, ProfileEditState>(
            builder: (context, state) {
              final isVerifying =
                  state.status == ProfileEditStatus.otpVerifying;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: AppColors.shadowColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  Text('Verify phone', style: AppTextStyles.cardTitle),
                  SizedBox(height: 6.h),
                  Text(
                    'Enter the OTP sent to your phone.',
                    style: AppTextStyles.cardMeta,
                  ),
                  SizedBox(height: 14.h),
                  TextField(
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    onChanged: context.read<ProfileEditCubit>().updateOtpCode,
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
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: state.canResend
                            ? context.read<ProfileEditCubit>().resendOtp
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
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isVerifying
                          ? null
                          : () =>
                              context.read<ProfileEditCubit>().verifyPhoneOtp(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: isVerifying
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
                ],
              );
            },
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
    required this.initialValue,
    required this.onChanged,
    this.keyboardType,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
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
