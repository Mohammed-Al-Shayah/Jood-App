import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/utils/extensions.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_section.dart';
import '../widgets/profile_utils.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: const ProfileTab(),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..load(),

      child: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == ProfileStatus.failure) {
              final message = state.errorMessage ?? 'Failed to load profile.';
              if (message.toLowerCase().contains('no signed-in user')) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Please log in to view your profile.',
                          style: AppTextStyles.cardMeta,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              context.pushNamedAndRemoveAll(Routes.loginScreen);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: const Text('Log in'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    message,
                    style: AppTextStyles.cardMeta,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            final user = state.user;
            if (user == null) {
              return Center(
                child: Text('No profile data.', style: AppTextStyles.cardMeta),
              );
            }

            final initials = profileInitials(user.fullName);
            final canScanOrders = _canScanOrders(user.role);
            final isAdmin = _isAdmin(user.role);
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileHeader(
                    initials: initials,
                    name: user.fullName,
                    email: user.email,
                    onEdit: () async {
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileEditScreen(user: user),
                        ),
                      );
                      if (updated == true && context.mounted) {
                        context.read<ProfileCubit>().load();
                      }
                    },
                  ),
                  SizedBox(height: 16.h),
                  ProfileInfoSection(
                    title: 'Contact',
                    items: [
                      ProfileInfoItem(
                        icon: Icons.phone,
                        label: 'Phone',
                        value: user.phone,
                      ),
                      ProfileInfoItem(
                        icon: Icons.mail_outline,
                        label: 'Email',
                        value: user.email,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  ProfileInfoSection(
                    title: 'Location',
                    items: [
                      ProfileInfoItem(
                        icon: Icons.public,
                        label: 'Country',
                        value: user.country,
                      ),
                      ProfileInfoItem(
                        icon: Icons.location_city,
                        label: 'City',
                        value: user.city,
                      ),
                    ],
                  ),
                  // SizedBox(height: 16.h),
                  // ProfileInfoSection(
                  //   title: 'Account',
                  //   items: [
                  //     ProfileInfoItem(
                  //       icon: Icons.verified_user_outlined,
                  //       label: 'Role',
                  //       value: user.role,
                  //     ),
                  //   ],
                  // ),
                  SizedBox(height: 16.h),
                  if (isAdmin) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.pushNamed(Routes.adminDashboardScreen);
                        },
                        icon: const Icon(Icons.admin_panel_settings_outlined),
                        label: const Text('Admin Dashboard'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                  if (canScanOrders) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.pushNamed(Routes.orderQrScannerScreen);
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Scan Order QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleDeleteAccount(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      icon: const Icon(Icons.delete_forever),
                      label: Text(
                        'Delete account',
                        style: AppTextStyles.cta.copyWith(color: Colors.red),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          context.pushNamedAndRemoveAll(Routes.loginScreen);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(color: AppColors.shadowColor),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: Text(
                        'Log out',
                        style: AppTextStyles.cta.copyWith(color: Colors.red),
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

Future<void> _handleDeleteAccount(BuildContext context) async {
  final step1 = await _showDeleteConfirmDialog(
    context,
    title: 'Delete account?',
    message:
        'This will permanently remove your account and all related data. You will not be able to recover it.',
    confirmLabel: 'Continue',
  );
  if (step1 != true || !context.mounted) return;

  final step2 = await _showDeleteConfirmDialog(
    context,
    title: 'Final confirmation',
    message: 'Are you absolutely sure? This action is irreversible.',
    confirmLabel: 'Delete account',
    isDestructive: true,
  );
  if (step2 != true || !context.mounted) return;

  _showBlockingLoading(context, 'Deleting your account...');
  try {
    final callable = FirebaseFunctions.instance.httpsCallable('deleteAccount');
    await callable.call();
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    showAppSnackBar(
      context,
      'Your account has been deleted.',
      type: SnackBarType.success,
    );
    context.pushNamedAndRemoveAll(Routes.loginScreen);
  } on FirebaseFunctionsException catch (e) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    if (_isReauthRequired(e)) {
      if (!context.mounted) return;
      await _showDeleteConfirmDialog(
        context,
        title: 'Re-authentication required',
        message:
            'Please log in again to confirm your identity, then retry deleting your account.',
        confirmLabel: 'Go to login',
        isDestructive: true,
      );
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        context.pushNamedAndRemoveAll(Routes.loginScreen);
      }
      return;
    }
    if (context.mounted) {
      showAppSnackBar(
        context,
        e.message ?? 'Unable to delete account. Please try again.',
        type: SnackBarType.error,
      );
    }
  } catch (_) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      showAppSnackBar(
        context,
        'Unable to delete account. Please try again.',
        type: SnackBarType.error,
      );
    }
  }
}

bool _isReauthRequired(FirebaseFunctionsException e) {
  final msg = (e.message ?? '').toLowerCase();
  return e.code == 'unauthenticated' ||
      e.code == 'failed-precondition' ||
      e.code == 'permission-denied' ||
      msg.contains('recent') ||
      msg.contains('reauth');
}

Future<bool?> _showDeleteConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool isDestructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
        contentPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
        actionsPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
        title: Text(title, style: AppTextStyles.sectionTitle),
        content: Text(message, style: AppTextStyles.bodySmall),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.shadowColor),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text('Cancel', style: AppTextStyles.cta.copyWith(color: AppColors.textPrimary)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDestructive ? Colors.red : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(confirmLabel, style: AppTextStyles.cta),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

void _showBlockingLoading(BuildContext context, String message) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return AlertDialog(
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        contentPadding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(message, style: AppTextStyles.body),
            ),
          ],
        ),
      );
    },
  );
}

bool _canScanOrders(String role) {
  final normalized = role.toLowerCase();
  return normalized == 'staff' ||
      normalized == 'restaurant_staff' ||
      normalized == 'admin';
}

bool _isAdmin(String role) {
  return role.toLowerCase() == 'admin';
}
