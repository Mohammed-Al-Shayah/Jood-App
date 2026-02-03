import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/app_strings.dart';

class BookingQrCard extends StatelessWidget {
  const BookingQrCard({super.key, required this.code, required this.qrData});

  final String code;
  final String qrData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 220.w,
            height: 220.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFE9EDF1)),
            ),
            child: Center(
              child: QrImageView(
                data: qrData,
                size: 188.w,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppStrings.bookingCodeLabel,
            style: AppTextStyles.cardMeta.copyWith(fontSize: 12.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            code,
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 14.sp),
          ),
          Divider(color: AppColors.shadowColor, height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.download, size: 16.sp),
                label: const Text('Download'),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.share_outlined, size: 16.sp),
                label: const Text('Share'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
