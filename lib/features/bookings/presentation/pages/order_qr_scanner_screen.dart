import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/utils/app_strings.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../cubit/order_qr_scanner_cubit.dart';

class OrderQrScannerScreen extends StatelessWidget {
  const OrderQrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderQrScannerCubit>(),
      child: const _OrderQrScannerView(),
    );
  }
}

class _OrderQrScannerView extends StatefulWidget {
  const _OrderQrScannerView();

  @override
  State<_OrderQrScannerView> createState() => _OrderQrScannerViewState();
}

class _OrderQrScannerViewState extends State<_OrderQrScannerView> {
  bool _isProcessing = false;
  bool _isSheetOpen = false;
  final ValueNotifier<String> _statusTextNotifier = ValueNotifier<String>(
    AppStrings.scanOrderQr,
  );

  @override
  void dispose() {
    _statusTextNotifier.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _isSheetOpen) return;
    final raw = capture.barcodes.isEmpty
        ? ''
        : (capture.barcodes.first.rawValue?.trim() ?? '');
    if (raw.isEmpty) return;

    _isProcessing = true;
    _statusTextNotifier.value = AppStrings.verifyingOrder;

    try {
      final bookingView = await context
          .read<OrderQrScannerCubit>()
          .loadBookingForCode(raw);
      if (!mounted) return;

      _isSheetOpen = true;
      bool? confirm;
      try {
        confirm = await showModalBottomSheet<bool>(
          context: context,
          isDismissible: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) => _BookingReviewSheet(
            bookingCode: bookingView.bookingCode,
            restaurantName: bookingView.restaurantName,
            date: bookingView.date,
            startTime: bookingView.startTime,
            adults: bookingView.adults,
            children: bookingView.children,
            subtotal: bookingView.pricing.subtotal,
            tax: bookingView.pricing.tax,
            total: bookingView.pricing.total,
            status: bookingView.status,
            offerTitle: bookingView.offerTitle,
          ),
        );
      } finally {
        _isSheetOpen = false;
      }

      if (confirm != true) {
        _statusTextNotifier.value = AppStrings.scanOrderQr;
        return;
      }

      if (!mounted) return;
      _statusTextNotifier.value = AppStrings.completingOrder;
      final completeText = await context
          .read<OrderQrScannerCubit>()
          .completeCurrentBooking();
      if (!mounted) return;

      _statusTextNotifier.value = completeText;
      showAppSnackBar(context, completeText, type: SnackBarType.success);
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '').trim();
      _statusTextNotifier.value = message;
      showAppSnackBar(context, message, type: SnackBarType.error);
    } finally {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.scanOrderQr)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(fit: BoxFit.cover, onDetect: _onDetect),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ValueListenableBuilder<String>(
                valueListenable: _statusTextNotifier,
                builder: (context, statusText, _) {
                  return Text(
                    statusText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingReviewSheet extends StatelessWidget {
  const _BookingReviewSheet({
    required this.bookingCode,
    required this.restaurantName,
    required this.date,
    required this.startTime,
    required this.adults,
    required this.children,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.offerTitle,
  });

  final String bookingCode;
  final String restaurantName;
  final String date;
  final String startTime;
  final int adults;
  final int children;
  final double subtotal;
  final double tax;
  final double total;
  final String status;
  final String offerTitle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.orderDetails,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _line(AppStrings.code, bookingCode),
              _line(AppStrings.restaurant, restaurantName),
              _line(AppStrings.date, date),
              _line(AppStrings.time, startTime),
              _line(
                AppStrings.guests,
                AppStrings.guestsSummary(adults, children),
              ),
              _line(AppStrings.subtotal, subtotal.toStringAsFixed(2)),
              _line(AppStrings.vat, tax.toStringAsFixed(2)),
              _line(AppStrings.total, total.toStringAsFixed(2)),
              _line(AppStrings.couponOffer, offerTitle, maxLines: 2),
              _line(AppStrings.status, status),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(
                        AppStrings.cancel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: AppColors.mainBlue,
                      ),
                      child: Text(
                        AppStrings.confirmAndComplete,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(String title, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
