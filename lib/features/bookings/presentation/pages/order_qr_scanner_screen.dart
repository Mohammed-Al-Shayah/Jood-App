import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/booking_review_view_model.dart';
import '../models/scanner_models.dart';

class OrderQrScannerScreen extends StatefulWidget {
  const OrderQrScannerScreen({super.key});

  @override
  State<OrderQrScannerScreen> createState() => _OrderQrScannerScreenState();
}

class _OrderQrScannerScreenState extends State<OrderQrScannerScreen> {
  bool _isProcessing = false;
  bool _isSheetOpen = false;
  final ValueNotifier<String> _statusTextNotifier = ValueNotifier<String>(
    'Scan order QR',
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
    _statusTextNotifier.value = 'Verifying order...';

    try {
      final code = raw.startsWith('BOOKING:') ? raw.substring(8).trim() : raw;
      if (code.isEmpty) {
        throw Exception('Invalid QR code.');
      }

      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        throw Exception('No signed-in user.');
      }

      final db = FirebaseFirestore.instance;
      final staffDoc = await db.collection('users').doc(authUser.uid).get();
      final staff = StaffAccessModel.fromDoc(staffDoc);

      if (!staff.canRedeemOrder) {
        throw Exception('Only restaurant staff can redeem orders.');
      }
      if (staff.restaurantId.isEmpty) {
        throw Exception('Staff account missing restaurant id.');
      }

      final booking = await _loadBookingForStaff(
        code: code,
        staffRestaurantId: staff.restaurantId,
      );
      var bookingView = BookingReviewViewModel.fromValues(
        bookingId: booking.id,
        bookingCode: booking.bookingCode,
        restaurantId: booking.restaurantId,
        offerId: booking.offerId,
        date: booking.date,
        startTime: booking.startTime,
        adults: booking.adults,
        children: booking.children,
        status: booking.status,
        subtotal: booking.subtotal,
        tax: booking.tax,
        total: booking.total,
        restaurantNameSnapshot: booking.restaurantNameSnapshot,
        offerTitleSnapshot: booking.offerTitleSnapshot,
        fallbackCode: code,
      );
      final restaurantName = bookingView.restaurantName.isNotEmpty
          ? bookingView.restaurantName
          : await _restaurantName(bookingView.restaurantId);
      final offerTitle = bookingView.offerTitle.isNotEmpty
          ? bookingView.offerTitle
          : await _offerTitle(bookingView.offerId);
      bookingView = bookingView.copyWith(
        restaurantName: restaurantName,
        offerTitle: offerTitle,
      );

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
        _statusTextNotifier.value = 'Scan order QR';
        return;
      }

      final completeText = await _completeBooking(
        bookingId: bookingView.bookingId,
        staffRestaurantId: staff.restaurantId,
        uid: authUser.uid,
      );
      if (!mounted) return;
      _statusTextNotifier.value = completeText;
      showAppSnackBar(context, completeText, type: SnackBarType.success);
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '').trim();
      _statusTextNotifier.value = message;
      showAppSnackBar(context, message, type: SnackBarType.error);
    } finally {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      _isProcessing = false;
    }
  }

  Future<ScannedBookingModel> _loadBookingForStaff({
    required String code,
    required String staffRestaurantId,
  }) async {
    final db = FirebaseFirestore.instance;
    final bookingQuery = await db
        .collection('bookings')
        .where('bookingCode', isEqualTo: code)
        .limit(1)
        .get();
    if (bookingQuery.docs.isEmpty) {
      throw Exception('Order not found.');
    }
    final booking = ScannedBookingModel.fromDoc(bookingQuery.docs.first);
    if (booking.restaurantId != staffRestaurantId) {
      throw Exception('This order belongs to another restaurant.');
    }
    if (booking.status == 'completed') {
      throw Exception('Order already completed.');
    }
    if (booking.status != 'paid' && booking.status != 'confirmed') {
      throw Exception('Order is not paid.');
    }
    return booking;
  }

  Future<String> _completeBooking({
    required String bookingId,
    required String staffRestaurantId,
    required String uid,
  }) async {
    final db = FirebaseFirestore.instance;
    final bookingRef = db.collection('bookings').doc(bookingId);
    return db.runTransaction((tx) async {
      final bookingSnap = await tx.get(bookingRef);
      final booking = ScannedBookingModel.fromDoc(bookingSnap);

      if (booking.restaurantId != staffRestaurantId) {
        throw Exception('This order belongs to another restaurant.');
      }
      if (booking.status == 'completed') {
        throw Exception('Order already completed.');
      }
      if (booking.status != 'paid' && booking.status != 'confirmed') {
        throw Exception('Order is not paid.');
      }

      tx.update(bookingRef, {
        'status': 'completed',
        'qrRedeemedAt': FieldValue.serverTimestamp(),
        'redeemedBy': uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return 'Order completed successfully.';
    });
  }

  Future<String> _restaurantName(String restaurantId) async {
    if (restaurantId.trim().isEmpty) return restaurantId;
    final doc = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(restaurantId)
        .get();
    final data = doc.data();
    return (data?['name'] as String?)?.trim().isNotEmpty == true
        ? (data?['name'] as String)
        : restaurantId;
  }

  Future<String> _offerTitle(String offerId) async {
    final cleaned = offerId.trim();
    if (cleaned.isEmpty) return '-';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('offers')
          .doc(cleaned)
          .get();
      final data = doc.data();
      final title = (data?['title'] as String? ?? '').trim();
      if (title.isNotEmpty) return title;
    } catch (_) {
      // Keep scanner flow working even if offers read fails.
    }
    return cleaned.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Order QR')),
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
                'Order details',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _line('Code', bookingCode),
              _line('Restaurant', restaurantName),
              _line('Date', date),
              _line('Time', startTime),
              _line('Guests', '$adults adult(s), $children child(ren)'),
              _line('Subtotal', subtotal.toStringAsFixed(2)),
              _line('Tax', tax.toStringAsFixed(2)),
              _line('Total', total.toStringAsFixed(2)),
              _line('Coupon/Offer', offerTitle, maxLines: 2),
              _line('Status', status),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text(
                        'Cancel',
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
                      child: const Text(
                        'Confirm & Complete',
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
