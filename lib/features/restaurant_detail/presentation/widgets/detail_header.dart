import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.image,
    required this.onBack,
  });

  final Widget image;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 240.h,
          width: double.infinity,
          child: image,
        ),
        Positioned(
          top: 12.h,
          left: 12.w,
          child: _CircleIconButton(
            icon: Icons.arrow_back,
            onTap: onBack,
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Icon(icon, size: 18.sp),
        ),
      ),
    );
  }
}
