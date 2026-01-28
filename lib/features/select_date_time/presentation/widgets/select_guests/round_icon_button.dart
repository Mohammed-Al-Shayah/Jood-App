import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/app_colors.dart';

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.isEnabled,
    required this.isFilled,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool isEnabled;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    final background = isFilled ? AppColors.primary : Colors.white;
    final borderColor = AppColors.primary.withValues(alpha: 0.3);
    final iconColor = isFilled ? Colors.white : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: Container(
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            color: isEnabled ? background : const Color(0xFFEFF1F4),
            shape: BoxShape.circle,
            border: Border.all(color: borderColor),
          ),
          child: Icon(icon, size: 16.sp, color: iconColor),
        ),
      ),
    );
  }
}
