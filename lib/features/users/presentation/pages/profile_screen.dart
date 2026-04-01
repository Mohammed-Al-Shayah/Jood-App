import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/extensions.dart';
import 'package:jood/core/widgets/app_snackbar.dart';

import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_utils.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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

            final canScanOrders = _canScanOrders(user.role);
            final isAdmin = _isAdmin(user.role);
            final quickActions = <_ProfileQuickAction>[
              if (isAdmin)
                _ProfileQuickAction(
                  title: 'Admin Dashboard',
                  subtitle: 'Manage offers, users, and activity.',
                  icon: Icons.admin_panel_settings_outlined,
                  tint: AppColors.primary,
                  onTap: () {
                    context.pushNamed(Routes.adminDashboardScreen);
                  },
                ),
              if (canScanOrders)
                _ProfileQuickAction(
                  title: 'Scan Order QR',
                  subtitle: 'Verify customer bookings on the spot.',
                  icon: Icons.qr_code_scanner_rounded,
                  tint: const Color(0xFF0F9D92),
                  onTap: () {
                    context.pushNamed(Routes.orderQrScannerScreen);
                  },
                ),
            ];

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profile', style: AppTextStyles.headingLarge),
                  SizedBox(height: 6.h),
                  Text(
                    'Manage your account details, access, and staff tools.',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 13.sp),
                  ),
                  SizedBox(height: 18.h),
                  _ProfileHeroCard(
                    initials: profileInitials(user.fullName),
                    name: user.fullName,
                    email: user.email,
                    role: _roleLabel(user.role),
                    location: _locationLabel(user.city, user.country),
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
                  if (quickActions.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    const _SectionHeading(
                      title: 'Quick Actions',
                      subtitle: 'Shortcuts available for your account role.',
                    ),
                    SizedBox(height: 12.h),
                    _QuickActionsGrid(actions: quickActions),
                  ],
                  SizedBox(height: 24.h),
                  const _SectionHeading(
                    title: 'Personal Info',
                    subtitle: 'Your saved details across the account.',
                  ),
                  SizedBox(height: 12.h),
                  _ProfileInfoCard(
                    items: [
                      _ProfileInfoEntry(
                        icon: Icons.phone_rounded,
                        label: 'Phone',
                        value: _fieldValue(user.phone),
                      ),
                      _ProfileInfoEntry(
                        icon: Icons.mail_outline_rounded,
                        label: 'Email',
                        value: _fieldValue(user.email),
                      ),
                      _ProfileInfoEntry(
                        icon: Icons.public_rounded,
                        label: 'Country',
                        value: _fieldValue(user.country),
                      ),
                      _ProfileInfoEntry(
                        icon: Icons.location_city_rounded,
                        label: 'City',
                        value: _fieldValue(user.city),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  const _SectionHeading(
                    title: 'Account',
                    subtitle: 'Session and access settings.',
                  ),
                  SizedBox(height: 12.h),
                  _ProfileActionPanel(
                    icon: Icons.logout_rounded,
                    title: 'Log out',
                    subtitle: 'Sign out from this device and return to login.',
                    tint: AppColors.textPrimary,
                    onTap: () async {
                      final message = await context
                          .read<ProfileCubit>()
                          .signOut();
                      if (!context.mounted) return;
                      if (message != null) {
                        showAppSnackBar(
                          context,
                          message,
                          type: SnackBarType.error,
                        );
                        return;
                      }
                      if (context.mounted) {
                        context.pushNamedAndRemoveAll(Routes.loginScreen);
                      }
                    },
                  ),
                  SizedBox(height: 24.h),
                  const _SectionHeading(
                    title: 'Danger Zone',
                    subtitle: 'Permanent actions that remove your account.',
                  ),
                  SizedBox(height: 12.h),
                  _DangerZoneCard(
                    onDelete: () => _handleDeleteAccount(context),
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

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.initials,
    required this.name,
    required this.email,
    required this.role,
    required this.location,
    required this.onEdit,
  });

  final String initials;
  final String name;
  final String email;
  final String role;
  final String location;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.primary.withValues(alpha: 0.12),
            const Color(0xFFEAFBF8),
          ],
        ),
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 18.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 74.w,
                  height: 74.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.16),
                        AppColors.primary.withValues(alpha: 0.28),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: AppTextStyles.headingMedium.copyWith(
                        color: AppColors.primaryDark,
                        fontSize: 24.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.cardTitle.copyWith(
                          fontSize: 22.sp,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        email,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _HeroEditButton(onTap: onEdit),
              ],
            ),
            SizedBox(height: 18.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: [
                _HeroBadge(icon: Icons.shield_outlined, label: role),
                if (location.isNotEmpty)
                  _HeroBadge(icon: Icons.location_on_outlined, label: location),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroEditButton extends StatelessWidget {
  const _HeroEditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.82),
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_outlined, size: 16.sp, color: AppColors.primary),
              SizedBox(width: 6.w),
              Text(
                'Edit',
                style: AppTextStyles.body.copyWith(
                  fontSize: 13.sp,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.sp, color: AppColors.primaryDark),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 17.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(fontSize: 12.sp),
        ),
      ],
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({required this.actions});

  final List<_ProfileQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = actions.length > 1 && constraints.maxWidth > 280;
        final columns = useTwoColumns ? 2 : 1;
        final spacing = 12.w;
        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: 12.h,
          children: actions
              .map(
                (action) => SizedBox(
                  width: itemWidth,
                  child: _QuickActionCard(action: action),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});

  final _ProfileQuickAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22.r),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: action.tint.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 14.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: action.tint.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(action.icon, color: action.tint, size: 22.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                action.title,
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 15.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                action.subtitle,
                style: AppTextStyles.bodySmall.copyWith(height: 1.35),
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Text(
                    'Open',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 13.sp,
                      color: action.tint,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: action.tint,
                    size: 18.sp,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.items});

  final List<_ProfileInfoEntry> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: _ProfileInfoTile(item: item),
              ),
              if (index != items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.iconStroke,
                  indent: 16.w,
                  endIndent: 16.w,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({required this.item});

  final _ProfileInfoEntry item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(item.icon, color: AppColors.primary, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                item.value,
                style: AppTextStyles.body.copyWith(
                  fontSize: 15.sp,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileActionPanel extends StatelessWidget {
  const _ProfileActionPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 14.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(icon, color: tint, size: 22.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.sectionTitle),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(height: 1.35),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DangerZoneCard extends StatelessWidget {
  const _DangerZoneCard({required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F7),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.red.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.delete_forever_outlined,
                  color: Colors.red,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Delete account',
                  style: AppTextStyles.sectionTitle.copyWith(color: Colors.red),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'This permanently removes your account and related data. You will not be able to recover it later.',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.sp,
              height: 1.45,
              color: const Color(0xFF8F4B4B),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDelete,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              icon: const Icon(Icons.delete_forever),
              label: Text(
                'Delete account',
                style: AppTextStyles.body.copyWith(
                  fontSize: 14.sp,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileQuickAction {
  const _ProfileQuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;
}

class _ProfileInfoEntry {
  const _ProfileInfoEntry({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
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
  final result = await context.read<ProfileCubit>().deleteAccount();
  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pop();
  if (result.status == ProfileAccountActionStatus.success) {
    showAppSnackBar(context, result.message, type: SnackBarType.success);
    context.pushNamedAndRemoveAll(Routes.loginScreen);
    return;
  }
  if (result.status == ProfileAccountActionStatus.reauthRequired) {
    await _showDeleteConfirmDialog(
      context,
      title: 'Re-authentication required',
      message: result.message,
      confirmLabel: 'Go to login',
      isDestructive: true,
    );
    if (context.mounted) {
      context.pushNamedAndRemoveAll(Routes.loginScreen);
    }
    return;
  }
  showAppSnackBar(context, result.message, type: SnackBarType.error);
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
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.cta.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDestructive
                        ? Colors.red
                        : AppColors.primary,
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
            Expanded(child: Text(message, style: AppTextStyles.body)),
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

String _fieldValue(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? 'Not added yet' : trimmed;
}

String _locationLabel(String city, String country) {
  final parts = [
    if (city.trim().isNotEmpty) city.trim(),
    if (country.trim().isNotEmpty) country.trim(),
  ];
  return parts.join(', ');
}

String _roleLabel(String role) {
  final normalized = role.trim().toLowerCase();
  switch (normalized) {
    case 'admin':
      return 'Administrator';
    case 'restaurant_staff':
      return 'Restaurant Staff';
    case 'staff':
      return 'Staff';
    case '':
      return 'Member';
    default:
      final words = normalized.split('_');
      return words
          .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
          .join(' ');
  }
}
