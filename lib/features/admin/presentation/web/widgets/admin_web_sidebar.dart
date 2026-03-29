import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/features/admin/presentation/web/admin_web_shell_screen.dart';
import 'package:jood/features/users/domain/entities/user_entity.dart';

class AdminWebSidebar extends StatelessWidget {
  const AdminWebSidebar({
    super.key,
    required this.currentUser,
    required this.selectedSection,
    required this.onSelectSection,
    required this.onSignOut,
    this.collapsed = false,
  });

  final UserEntity currentUser;
  final AdminWebSection selectedSection;
  final ValueChanged<AdminWebSection> onSelectSection;
  final VoidCallback onSignOut;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: collapsed ? 92.0 : 280.0,
      color: const Color(0xFF0F172A),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
          children: [
            Container(
              width: collapsed ? 56.w : double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: collapsed ? 0 : 16.w,
                vertical: 16.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(22.r),
              ),
              child: collapsed
                  ? Icon(
                      Icons.dashboard_customize_outlined,
                      color: Colors.white,
                      size: 28.sp,
                    )
                  : Row(
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Image.asset(
                            'assets/images/logo2.png',
                            width: 24.w,
                            height: 24.w,
                          ),
                          // Icon(
                          //   Icons.dashboard_customize_outlined,
                          //   color: Colors.white,
                          //   size: 24.sp,
                          // ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jood Admin',
                                style: AppTextStyles.cardTitle.copyWith(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              // Text(
                              //   'Flutter Web',
                              //   style: AppTextStyles.cardMeta.copyWith(
                              //     color: Colors.white.withValues(alpha: 0.72),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            SizedBox(height: 28.h),
            for (final section in AdminWebSection.values) ...[
              _SidebarItem(
                section: section,
                selected: section == selectedSection,
                collapsed: collapsed,
                onTap: () => onSelectSection(section),
              ),
              SizedBox(height: 8.h),
            ],
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: collapsed
                  ? Icon(
                      Icons.person_outline,
                      color: Colors.white.withValues(alpha: 0.88),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.sectionTitle.copyWith(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          currentUser.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.cardMeta.copyWith(
                            color: Colors.white.withValues(alpha: 0.68),
                          ),
                        ),
                      ],
                    ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onSignOut,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                icon: const Icon(Icons.logout_outlined),
                label: collapsed
                    ? const SizedBox.shrink()
                    : const Text('Sign out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.section,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  final AdminWebSection section;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = selected
        ? Colors.white
        : Colors.white.withValues(alpha: 0.72);

    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 0 : 14.w,
            vertical: 14.h,
          ),
          child: collapsed
              ? Center(
                  child: Icon(
                    section.icon,
                    color: foregroundColor,
                    size: 22.sp,
                  ),
                )
              : Row(
                  children: [
                    Icon(section.icon, color: foregroundColor, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        section.label,
                        style: AppTextStyles.cardMeta.copyWith(
                          color: foregroundColor,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
