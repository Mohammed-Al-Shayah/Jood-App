import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';

Future<bool?> showAdminConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        backgroundColor: AppColors.cardBackground,
        title: Text(title, style: AppTextStyles.sectionTitle),
        content: Text(
          message,
          style: AppTextStyles.cardMeta.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.cardMeta.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Delete',
              style: AppTextStyles.cardMeta.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    },
  );
}
