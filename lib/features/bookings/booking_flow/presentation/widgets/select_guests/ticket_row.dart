import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/widgets/currency_amount_text.dart';
import 'round_icon_button.dart';

class TicketRow extends StatelessWidget {
  const TicketRow({
    super.key,
    required this.label,
    this.ageLabel = '',
    this.priceLabel = '',
    this.priceWidget,
    required this.count,
    required this.onAdd,
    required this.onRemove,
  });

  final String label;
  final String ageLabel;
  final String priceLabel;
  final Widget? priceWidget;
  final int count;
  final VoidCallback? onAdd;
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
              if (ageLabel.trim().isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  ageLabel,
                  style: AppTextStyles.cardMeta.copyWith(fontSize: 12.sp),
                ),
              ],
              SizedBox(height: 6.h),
              priceWidget ??
                  CurrencyAmountInlineText(
                    text: priceLabel,
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
              isEnabled: onAdd != null,
              isFilled: true,
            ),
          ],
        ),
      ],
    );
  }
}
