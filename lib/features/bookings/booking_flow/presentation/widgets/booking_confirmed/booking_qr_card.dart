import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/app_strings.dart';

class BookingQrCard extends StatelessWidget {
  const BookingQrCard({super.key, required this.code, required this.qrData});

  final String code;
  final String qrData;

  Future<Uint8List> _buildQrBytes() async {
    final painter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
      gapless: true,
      color: Colors.black,
      emptyColor: Colors.white,
    );
    final imageData = await painter.toImageData(1024);
    if (imageData == null) {
      throw Exception('Failed to generate QR image.');
    }
    return imageData.buffer.asUint8List();
  }

  Future<File> _saveQrToFile() async {
    final bytes = await _buildQrBytes();
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/qr_codes');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final safeCode = code.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final file = File(
      '${folder.path}/booking_qr_${safeCode}_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> _downloadQr(BuildContext context) async {
    try {
      final bytes = await _buildQrBytes();
      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: 100,
        name: 'booking_qr_$code',
      );
      final isSaved =
          result['isSuccess'] == true ||
          (result['filePath']?.toString().isNotEmpty ?? false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSaved ? 'QR saved to gallery.' : 'Could not save QR to gallery.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save QR to gallery: $error')),
      );
    }
  }

  Future<void> _shareQr(BuildContext context) async {
    try {
      final file = await _saveQrToFile();
      await Share.shareXFiles([XFile(file.path)], text: 'Booking Code: $code');
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to share QR: $error')));
    }
  }

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
                onPressed: () => _downloadQr(context),
                icon: Icon(Icons.download, size: 16.sp),
                label: const Text('Download'),
              ),
              TextButton.icon(
                onPressed: () => _shareQr(context),
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
