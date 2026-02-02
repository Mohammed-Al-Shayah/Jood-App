import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomCtaBar extends StatelessWidget {
  const BottomCtaBar({
    super.key,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.shadowColor,
    required this.textStyle,
    required this.buttonColor,
    this.padding,
  });

  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color shadowColor;
  final TextStyle textStyle;
  final Color buttonColor;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 14.r,
            offset: Offset(0, -6.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              elevation: 0,
            ),
            child: Text(label, style: textStyle),
          ),
        ),
      ),
    );
  }
}
