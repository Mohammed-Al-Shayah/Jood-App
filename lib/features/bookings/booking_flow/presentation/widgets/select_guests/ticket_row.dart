import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/theming/app_text_styles.dart';
import 'round_icon_button.dart';

class TicketRow extends StatelessWidget {
  const TicketRow({
    super.key,
    required this.label,
    required this.ageLabel,
    required this.priceLabel,
    required this.count,
    required this.onAdd,
    required this.onRemove,
  });

  final String label;
  final String ageLabel;
  final String priceLabel;
  final int count;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 14.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                ageLabel,
                style: AppTextStyles.cardMeta.copyWith(fontSize: 12.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                priceLabel,
                style: AppTextStyles.cardPrice.copyWith(fontSize: 14.sp),
              ),
            ],
          ),
        ),
        Row(
          children: [
            RoundIconButton(
              icon: Icons.remove,
              onTap: onRemove,
              isEnabled: onRemove != null,
              isFilled: false,
            ),
            SizedBox(width: 10.w),
            Text(
              '$count',
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 16.sp),
            ),
            SizedBox(width: 10.w),
            RoundIconButton(
              icon: Icons.add,
              onTap: onAdd,
              isEnabled: true,
              isFilled: true,
            ),
          ],
        ),
      ],
    );
  }
}


