import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jood/core/routing/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/utils/extensions.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/features/bookings/domain/usecases/create_booking_usecase.dart';
import 'package:jood/features/payments/domain/entities/payment_entity.dart';
import 'package:jood/features/payments/domain/usecases/create_payment_usecase.dart';
import 'package:jood/features/bookings/booking_flow/presentation/cubit/booking_flow_cubit.dart';
class PendingPayment {
  const PendingPayment({
    required this.sessionId,
    required this.offerId,
    required this.userId,
    required this.adults,
    required this.children,
    required this.totalAmount,
    required this.restaurantName,
  });

  final String sessionId;
  final String offerId;
  final String userId;
  final int adults;
  final int children;
  final double totalAmount;
  final String restaurantName;

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'offerId': offerId,
        'userId': userId,
        'adults': adults,
        'children': children,
        'totalAmount': totalAmount,
        'restaurantName': restaurantName,
      };

  static PendingPayment? fromJson(Map<String, dynamic> json) {
    final sessionId = (json['sessionId'] as String?)?.trim() ?? '';
    final offerId = (json['offerId'] as String?)?.trim() ?? '';
    final userId = (json['userId'] as String?)?.trim() ?? '';
    final restaurantName = (json['restaurantName'] as String?)?.trim() ?? '';
    if (sessionId.isEmpty || offerId.isEmpty || userId.isEmpty) return null;
    return PendingPayment(
      sessionId: sessionId,
      offerId: offerId,
      userId: userId,
      adults: (json['adults'] as num?)?.toInt() ?? 0,
      children: (json['children'] as num?)?.toInt() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      restaurantName: restaurantName,
    );
  }
}

class PaymentVerificationService {
  static const _pendingKey = 'pending_payment';
  static bool _checking = false;
  static bool _showingDialog = false;

  static Future<void> savePending(PendingPayment payment) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingKey, jsonEncode(payment.toJson()));
  }

  static Future<void> clearPending() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingKey);
  }

  static Future<PendingPayment?> _readPending() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingKey);
    if (raw == null || raw.trim().isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    return PendingPayment.fromJson(decoded);
  }

  static Future<void> checkAndHandlePendingPayment(
    BuildContext context, {
    BookingFlowCubit? cubit,
    bool showDialog = true,
  }) async {
    if (_checking) return;
    _checking = true;
    try {
      final pending = await _readPending();
      if (pending == null) return;

      if (showDialog) {
        _showCheckingDialog(context);
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.uid != pending.userId) return;

      final callable = FirebaseFunctions.instance.httpsCallable(
        'checkThawaniPayment',
      );
      final result = await callable
          .call({'sessionId': pending.sessionId})
          .timeout(const Duration(seconds: 20));
      final data = result.data is Map
          ? Map<String, dynamic>.from(result.data as Map)
          : <String, dynamic>{};
      final status = (data['status'] as String? ?? '').toLowerCase();

      if (status == 'paid' || status == 'success') {
        final booking = await getIt<CreateBookingUseCase>()(
          offerId: pending.offerId,
          userId: pending.userId,
          adults: pending.adults,
          children: pending.children,
        );

        await getIt<CreatePaymentUseCase>()(
          PaymentEntity(
            id: 'pay_${booking.id}_${DateTime.now().millisecondsSinceEpoch}',
            bookingId: booking.id,
            amount: pending.totalAmount,
            status: 'success',
            method: 'thawani',
            createdAt: DateTime.now(),
          ),
        );

        await clearPending();
        if (!context.mounted) return;
        showAppSnackBar(
          context,
          'Payment completed successfully.',
          type: SnackBarType.success,
        );
        context.pushNamed(
          Routes.bookingConfirmedScreen,
          arguments: BookingConfirmedArgs(
            restaurantName: pending.restaurantName,
            cubit: cubit ?? context.read<BookingFlowCubit>(),
            bookingCode: booking.bookingCode,
            qrData: booking.qrPayload,
          ),
        );
        return;
      }

      if (status == 'failed' ||
          status == 'canceled' ||
          status == 'cancelled') {
        await clearPending();
        if (context.mounted) {
          showAppSnackBar(
            context,
            'Payment failed or cancelled.',
            type: SnackBarType.error,
          );
        }
      }
    } catch (_) {
      // Keep pending for a later retry on resume.
    } finally {
      if (showDialog) {
        _hideCheckingDialog(context);
      }
      _checking = false;
    }
  }

  static void _showCheckingDialog(BuildContext context) {
    if (_showingDialog || !context.mounted) return;
    _showingDialog = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Payment is being verified ....'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _hideCheckingDialog(BuildContext context) {
    if (!_showingDialog) return;
    _showingDialog = false;
    if (!context.mounted) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }
}
