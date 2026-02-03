import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/utils/extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    state.errorMessage ?? 'Failed to load profile.',
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
                  if (user.role.toLowerCase() == 'staff' ||
                      user.role.toLowerCase() == 'restaurant_staff' ||
                      user.role.toLowerCase() == 'admin') ...[
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
