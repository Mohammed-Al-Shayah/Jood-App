import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_panel.dart';

class AdminWebInlineFormView extends StatelessWidget {
  const AdminWebInlineFormView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.child,
    this.backTooltip = 'Back',
    this.panelPadding,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final Widget child;
  final String backTooltip;
  final EdgeInsetsGeometry? panelPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              tooltip: backTooltip,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.cardMeta.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),
        Expanded(
          child: AdminWebPanel(
            padding: panelPadding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ],
    );
  }
}
