import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';

class AdminListTile extends StatelessWidget {
  const AdminListTile({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitles,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.isSelected = false,
    this.selectionMode = false,
  });

  final Widget leading;
  final String title;
  final List<Widget> subtitles;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final bool isSelected;
  final bool selectionMode;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Ink(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: isSelected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.4))
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withValues(alpha: 0.12),
              blurRadius: 16.r,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            leading,
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.cardTitle),
                  ...subtitles,
                ],
              ),
            ),
            if (selectionMode)
              Checkbox(
                value: isSelected,
                onChanged: (_) => onTap?.call(),
                activeColor: AppColors.primary,
              )
            else
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
              ),
          ],
        ),
      ),
    );
  }
}
