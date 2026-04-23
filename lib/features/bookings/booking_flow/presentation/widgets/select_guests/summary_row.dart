import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/widgets/currency_amount_text.dart';

class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.label,
    this.value = '',
    this.valueWidget,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Widget? valueWidget;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTextStyles.cardMeta.copyWith(
      fontSize: 13.sp,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
      color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        valueWidget ??
            CurrencyAmountInlineText(
              text: value,
              style: textStyle,
              textAlign: TextAlign.end,
            ),
      ],
    );
  }
}
