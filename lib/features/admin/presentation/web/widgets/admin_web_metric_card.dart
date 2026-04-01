import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';

import 'admin_web_panel.dart';

class AdminWebMetricCard extends StatelessWidget {
  const AdminWebMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.caption,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? caption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 250;
        final padding = compact ? 16.0 : 20.0;
        final minHeight = compact ? 156.0 : 172.0;
        final iconSize = compact ? 46.0 : 52.0;
        final valueSize = compact ? 28.0 : 32.0;

        final content = ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: compact ? 22.0 : 24.0,
                    ),
                  ),
                  SizedBox(width: compact ? 10.0 : 12.0),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: compact ? 13.0 : 14.0,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 16.0 : 20.0),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: valueSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 12.h),
              Container(height: 1, color: const Color(0xFFE9EEF5)),
              if (caption != null && caption!.trim().isNotEmpty) ...[
                SizedBox(height: 12.h),
                Text(
                  caption!,
                  maxLines: compact ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardMeta.copyWith(
                    color: AppColors.textMuted,
                    fontSize: compact ? 11.0 : 12.0,
                    height: 1.5,
                  ),
                ),
              ] else ...[
                SizedBox(height: 12.h),
                Text(
                  'Live dashboard summary',
                  style: AppTextStyles.cardMeta.copyWith(
                    color: AppColors.textMuted,
                    fontSize: compact ? 11.0 : 12.0,
                  ),
                ),
              ],
            ],
          ),
        );

        final card = AdminWebPanel(
          padding: EdgeInsets.all(padding),
          child: content,
        );

        if (onTap == null) {
          return card;
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24.r),
            child: card,
          ),
        );
      },
    );
  }
}
