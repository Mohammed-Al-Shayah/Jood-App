import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_picker/country_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/auth_validators.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
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
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _seedPhoneField();
  }

  Future<void> _seedPhoneField() async {
    final rawPhone = widget.user.phone.trim();
    if (rawPhone.isEmpty) return;

    final normalized = AuthValidators.normalizePhone(rawPhone);
    final candidates = <String>{
      rawPhone,
      normalized,
      if (normalized.isNotEmpty) '+$normalized',
    };

    for (final candidate in candidates) {
      if (candidate.trim().isEmpty) continue;
      try {
        final info = await PhoneNumber.getRegionInfoFromPhoneNumber(candidate);
        final localNumber = await PhoneNumber.getParsableNumber(
          PhoneNumber(
            phoneNumber: info.phoneNumber ?? candidate,
            dialCode: info.dialCode,
            isoCode: info.isoCode,
          ),
        );
        if (!mounted) return;
        if (localNumber.trim().isNotEmpty) {
          _phoneController.text = localNumber.trim();
          return;
        }
      } catch (_) {
        // Try the next phone representation.
      }
    }

    _phoneController.text = normalized;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileEditCubit(
        updateUser: getIt(),
        getUserByPhone: getIt(),
        sendPhoneOtp: getIt(),
        verifyOtp: getIt(),
        getCurrentUser: getIt(),
        reloadUser: getIt(),
        signOut: getIt(),
        verifyBeforeUpdateEmail: getIt(),
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
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SafeArea(
            child: BlocConsumer<ProfileEditCubit, ProfileEditState>(
              listener: (context, state) {
                if (state.status == ProfileEditStatus.success) {
                  if (state.successMessage != null) {
                    showAppSnackBar(
                      context,
                      state.successMessage!,
                      type: SnackBarType.success,
                    );
                  }
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
                  showAppSnackBar(
                    context,
                    state.errorMessage!,
                    type: SnackBarType.error,
                  );
                }
                if (state.status == ProfileEditStatus.otpSent &&
                    !_otpSheetOpen) {
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
                final isSaving =
                    state.status == ProfileEditStatus.saving ||
                    state.status == ProfileEditStatus.otpSending ||
                    state.status == ProfileEditStatus.otpVerifying;
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    _Label(text: 'Full name'),
                    _Field(
                      initialValue: state.fullName,
                      onChanged: context
                          .read<ProfileEditCubit>()
                          .updateFullName,
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
                      ),
                      textFieldController: _phoneController,
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
                    _PickerField(
                      hintText: 'Select country',
                      value: state.country,
                      onTap: () => _showCountryPicker(
                        context,
                        (country) => context
                            .read<ProfileEditCubit>()
                            .updateCountry(country.name),
                      ),
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
      ),
    );
  }
}

Future<void> _showOtpSheet(BuildContext context, ProfileEditCubit cubit) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (sheetContext) {
      return BlocProvider.value(
        value: cubit,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
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
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          maxLength: 6,
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          onChanged:
                              context.read<ProfileEditCubit>().updateOtpCode,
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
                              : () => context
                                    .read<ProfileEditCubit>()
                                    .verifyPhoneOtp(),
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
            ),
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
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
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

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.hintText,
    required this.value,
    required this.onTap,
  });

  final String hintText;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEmpty = value.trim().isEmpty;
    return InkWell(
      borderRadius: BorderRadius.circular(30.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7FB),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                isEmpty ? hintText : value,
                style: AppTextStyles.cardMeta.copyWith(
                  color: isEmpty ? AppColors.textMuted : AppColors.textPrimary,
                  fontSize: 14.sp,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

void _showCountryPicker(BuildContext context, ValueChanged<Country> onSelect) {
  showCountryPicker(
    context: context,
    showPhoneCode: false,
    showSearch: true,
    countryListTheme: CountryListThemeData(
      backgroundColor: Colors.white,
      textStyle: AppTextStyles.cardMeta.copyWith(
        fontSize: 15.sp,
        color: AppColors.textPrimary,
      ),
      inputDecoration: InputDecoration(
        hintText: 'Search country',
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
      ),
    ),
    onSelect: onSelect,
  );
}
