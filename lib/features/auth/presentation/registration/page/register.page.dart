import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import 'package:country_picker/country_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:jood/core/config/turnstile_config.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/utils/app_strings.dart';
import 'package:jood/core/utils/extensions.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import '../../otp/verify_otp_args.dart';
import '../logic/register_cubit.dart';
import '../logic/register_state.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RegisterCubit>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final TurnstileController _turnstileController = TurnstileController();

  bool _isTurnstileListenerAttached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isTurnstileListenerAttached) return;
    _isTurnstileListenerAttached = true;
    _turnstileController.onTokenReceived((token) {
      if (!mounted) return;
      context.read<RegisterCubit>().setTurnstileToken(token);
    });
  }

  @override
  void dispose() {
    _turnstileController.dispose();
    super.dispose();
  }

  String get _turnstileToken => _turnstileController.token?.trim() ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppStrings.signUp),
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
              showAppSnackBar(
                context,
                state.errorMessage!,
                type: SnackBarType.error,
              );
            }
            if (state.status == RegisterStatus.phoneOtpSent &&
                state.verificationId != null) {
              context.pushNamed(
                Routes.verifyOtpScreen,
                arguments: VerifyOtpArgs.registration(
                  verificationId: state.verificationId!,
                  resendToken: state.resendToken,
                  fullName: state.fullName.trim(),
                  password: state.password,
                  email: state.email.trim(),
                  phone: state.phone.trim(),
                  country: state.country.trim(),
                  city: state.city.trim(),
                ),
              );
            }
            if (state.status == RegisterStatus.phoneVerified) {
              context.pushNamedAndRemoveAll(Routes.homeScreen);
            }
          },
          builder: (context, state) {
            final isLoading = state.status == RegisterStatus.loading;
            final resolvedTurnstileToken =
                state.turnstileToken.trim().isNotEmpty
                ? state.turnstileToken.trim()
                : _turnstileToken;
            final isTurnstileVerified =
                !TurnstileConfig.isConfigured ||
                resolvedTurnstileToken.isNotEmpty;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label(text: AppStrings.fullName),
                  _Field(
                    hintText: AppStrings.enterFullName,
                    onChanged: context.read<RegisterCubit>().updateFullName,
                    errorText: state.fullNameError,
                  ),
                  _Label(text: AppStrings.emailAddress),
                  _Field(
                    hintText: AppStrings.enterEmail,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: context.read<RegisterCubit>().updateEmail,
                    errorText: state.emailError,
                  ),
                  _Label(text: AppStrings.password),
                  _Field(
                    hintText: AppStrings.createPassword,
                    obscureText: !state.showPassword,
                    onChanged: context.read<RegisterCubit>().updatePassword,
                    errorText: state.passwordError,
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
                  _Label(text: AppStrings.confirmPassword),
                  _Field(
                    hintText: AppStrings.confirmPasswordHint,
                    obscureText: !state.showConfirmPassword,
                    onChanged: context
                        .read<RegisterCubit>()
                        .updateConfirmPassword,
                    errorText: state.confirmPasswordError,
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
                  _Label(text: AppStrings.phoneNumberForOtp),
                  InternationalPhoneNumberInput(
                    initialValue: PhoneNumber(isoCode: state.phoneIso),
                    onInputChanged: (number) {
                      context.read<RegisterCubit>().updatePhone(
                        number.phoneNumber ?? '',
                      );
                      final iso = number.isoCode;
                      if (iso != null && iso.isNotEmpty) {
                        context.read<RegisterCubit>().updatePhoneIso(iso);
                      }
                    },
                    selectorConfig: const SelectorConfig(
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    ),
                    keyboardType: TextInputType.phone,
                    inputDecoration: InputDecoration(
                      hintText: AppStrings.enterPhoneNumber,
                      errorText: state.phoneError,
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
                  _Label(text: AppStrings.country),
                  _PickerField(
                    hintText: AppStrings.selectCountry,
                    value: state.country,
                    onTap: () => _showCountryPicker(
                      context,
                      (country) => context.read<RegisterCubit>().updateCountry(
                        country.name,
                      ),
                    ),
                    errorText: state.countryError,
                  ),
                  _Label(text: AppStrings.city),
                  _Field(
                    hintText: AppStrings.city,
                    onChanged: context.read<RegisterCubit>().updateCity,
                    errorText: state.cityError,
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
                          AppStrings.agreeToTermsAndPrivacyPolicy,
                          style: AppTextStyles.cardMeta.copyWith(
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (state.termsError != null)
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: 8.w, top: 4.h),
                      child: Text(
                        state.termsError!,
                        style: AppTextStyles.cardMeta.copyWith(
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  SizedBox(height: 12.h),
                  if (TurnstileConfig.isConfigured) ...[
                    Text(
                      AppStrings.completeSecurityCheckBeforeSendingOtp,
                      style: AppTextStyles.cardMeta.copyWith(fontSize: 12.sp),
                    ),
                    SizedBox(height: 8.h),
                    Center(
                      child: CloudflareTurnstile(
                        controller: _turnstileController,
                        siteKey: TurnstileConfig.siteKey,
                        baseUrl: TurnstileConfig.baseUrl,
                        action: 'register',
                        onTokenReceived: (token) {
                          context.read<RegisterCubit>().setTurnstileToken(
                            token,
                          );
                        },
                        onTokenExpired: () {
                          context.read<RegisterCubit>().clearTurnstileToken();
                        },
                        onTimeout: () {
                          context.read<RegisterCubit>().clearTurnstileToken();
                          showAppSnackBar(
                            context,
                            AppStrings.securityCheckFailedPleaseTryAgain,
                            type: SnackBarType.error,
                          );
                        },
                        onError: (error) {
                          context.read<RegisterCubit>().clearTurnstileToken();
                          showAppSnackBar(
                            context,
                            error.message.isEmpty
                                ? AppStrings.securityCheckFailedPleaseTryAgain
                                : error.message,
                            type: SnackBarType.error,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      isTurnstileVerified
                          ? AppStrings.done
                          : AppStrings.completeSecurityCheckBeforeSendingOtp,
                      style: AppTextStyles.cardMeta.copyWith(
                        fontSize: 11.sp,
                        color: isTurnstileVerified
                            ? Colors.green
                            : AppColors.textMuted,
                      ),
                    ),
                  ] else
                    Text(
                      AppStrings.securityCheckNotConfigured,
                      style: AppTextStyles.cardMeta.copyWith(
                        fontSize: 12.sp,
                        color: Colors.redAccent,
                      ),
                    ),
                  SizedBox(height: 20.h),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            state.isValid && !isLoading && isTurnstileVerified
                            ? () => context.read<RegisterCubit>().submit(
                                turnstileToken: resolvedTurnstileToken,
                              )
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
                                AppStrings.sendOtp,
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
    this.errorText,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffix,
        errorText: errorText,
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
    this.errorText,
  });

  final String hintText;
  final String value;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final isEmpty = value.trim().isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
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
                      color: isEmpty
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: EdgeInsetsDirectional.only(start: 16.w, top: 4.h),
            child: Text(
              errorText!,
              style: AppTextStyles.cardMeta.copyWith(color: Colors.redAccent),
            ),
          ),
      ],
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
        hintText: AppStrings.searchCountry,
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
