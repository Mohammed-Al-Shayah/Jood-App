import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/extensions.dart';
import 'package:jood/features/admin/presentation/widgets/admin_shell.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Admin Dashboard',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeaderCard(),
          SizedBox(height: 18.h),
          Text('Management', style: AppTextStyles.sectionTitle),
          SizedBox(height: 12.h),
          _AdminActionCard(
            icon: Icons.restaurant_menu,
            title: 'Restaurants',
            subtitle: 'Add, edit, and manage listings',
            onTap: () => context.pushNamed(Routes.adminRestaurantsScreen),
          ),
          SizedBox(height: 12.h),
          _AdminActionCard(
            icon: Icons.local_offer_outlined,
            title: 'Offers',
            subtitle: 'Create time slots and pricing',
            onTap: () => context.pushNamed(Routes.adminOffersScreen),
          ),
          SizedBox(height: 12.h),
          _AdminActionCard(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Users & Roles',
            subtitle: 'Assign access and roles',
            onTap: () => context.pushNamed(Routes.adminUsersScreen),
          ),
        ],
      ),
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  const _AdminActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: Ink(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.12),
              blurRadius: 16.r,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.cardTitle),
                  SizedBox(height: 4.h),
                  Text(subtitle, style: AppTextStyles.cardMeta),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.ctaShadow.withOpacity(0.35),
            blurRadius: 18.r,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: const Icon(Icons.dashboard_outlined, color: Colors.white),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Control Center',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Manage restaurants, offers, and users in one place.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
