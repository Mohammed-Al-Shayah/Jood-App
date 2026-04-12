import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/features/admin/presentation/widgets/admin_shell.dart';
import 'package:jood/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:jood/features/bookings/domain/entities/booking_entity.dart';
import 'package:jood/features/bookings/domain/usecases/update_booking_refund_status_usecase.dart';
import 'package:jood/features/bookings/domain/usecases/watch_all_bookings_usecase.dart';
import 'package:jood/features/users/domain/entities/user_entity.dart';
import 'package:jood/features/users/domain/usecases/get_user_by_id_usecase.dart';

class AdminCancelledOrdersScreen extends StatelessWidget {
  const AdminCancelledOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = getIt<WatchAllBookingsUseCase>()();

    return AdminShell(
      title: 'Cancelled Orders',
      body: StreamBuilder<List<BookingEntity>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load orders: ${snapshot.error}'),
            );
          }

          final docs =
              List<BookingEntity>.from(
                (snapshot.data ?? const <BookingEntity>[]).where((booking) {
                  final status = booking.status.trim().toLowerCase();
                  return status == 'cancelled' || status == 'canceled';
                }),
              )..sort((a, b) {
                final aTime = a.cancelledAt ?? a.createdAt;
                final bTime = b.cancelledAt ?? b.createdAt;
                return bTime.compareTo(aTime);
              });
          if (docs.isEmpty) {
            return const Center(child: Text('No cancelled orders yet.'));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final booking = docs[index];
              final restaurantName =
                  (booking.restaurantNameSnapshot ?? '').trim().isNotEmpty
                  ? booking.restaurantNameSnapshot!.trim()
                  : booking.restaurantId;
              return _CancelledOrderCard(
                bookingId: booking.id,
                restaurantName: restaurantName.isEmpty
                    ? 'Restaurant'
                    : restaurantName,
                bookingCode: booking.bookingCode,
                date: booking.date,
                startTime: booking.startTime,
                total: booking.total,
                currency: booking.currency,
                userId: booking.userId,
                cancelledBy: (booking.cancelledBy ?? '').trim().isEmpty
                    ? '-'
                    : booking.cancelledBy!.trim(),
                cancelledByRole: (booking.cancelledByRole ?? '').trim(),
                cancelledAt: booking.cancelledAt,
                refundStatus: (booking.refundStatus ?? 'pending').trim(),
              );
            },
          );
        },
      ),
    );
  }
}

class _CancelledOrderCard extends StatelessWidget {
  const _CancelledOrderCard({
    required this.bookingId,
    required this.restaurantName,
    required this.bookingCode,
    required this.date,
    required this.startTime,
    required this.total,
    required this.currency,
    required this.userId,
    required this.cancelledBy,
    required this.cancelledByRole,
    required this.cancelledAt,
    required this.refundStatus,
  });

  final String bookingId;
  final String restaurantName;
  final String bookingCode;
  final String date;
  final String startTime;
  final double total;
  final String currency;
  final String userId;
  final String cancelledBy;
  final String cancelledByRole;
  final DateTime? cancelledAt;
  final String refundStatus;

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '-';
    return DateFormat('MMM d, yyyy - h:mm a').format(timestamp);
  }

  String _refundLabel(String status) {
    switch (status.toLowerCase()) {
      case 'checked':
        return 'Checked';
      case 'refunded':
        return 'Refunded';
      default:
        return 'Pending';
    }
  }

  bool _isRefunded(String status) => status.toLowerCase() == 'refunded';
  bool _isChecked(String status) => status.toLowerCase() == 'checked';

  Future<void> _updateRefundStatus(BuildContext context, String status) async {
    final currentUser = getIt<GetCurrentUserUseCase>()();
    final userId = currentUser?.uid ?? 'admin';
    try {
      await getIt<UpdateBookingRefundStatusUseCase>()(
        bookingId: bookingId,
        status: status,
        actorUserId: userId,
      );

      if (context.mounted) {
        showAppSnackBar(
          context,
          'Refund status updated.',
          type: SnackBarType.success,
        );
      }
    } catch (_) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          'Failed to update refund status.',
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final refundLabel = _refundLabel(refundStatus);
    final disabledChecked =
        _isChecked(refundStatus) || _isRefunded(refundStatus);
    final disabledRefunded = _isRefunded(refundStatus);
    final userFuture = userId.trim().isEmpty
        ? null
        : getIt<GetUserByIdUseCase>()(userId);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.12),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            restaurantName,
            style: AppTextStyles.sectionTitle,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text('Code: $bookingCode', style: AppTextStyles.cardMeta),
          SizedBox(height: 6.h),
          Text('$date  $startTime', style: AppTextStyles.cardMeta),
          SizedBox(height: 6.h),
          Text(
            'Total: $currency ${total.toStringAsFixed(1)}',
            style: AppTextStyles.cardPrice,
          ),
          SizedBox(height: 8.h),
          if (userFuture == null)
            Text('Customer: -', style: AppTextStyles.cardMeta)
          else
            FutureBuilder<UserEntity?>(
              future: userFuture,
              builder: (context, snapshot) {
                final fullName = (snapshot.data?.fullName ?? '').trim();
                final displayName = fullName.isNotEmpty ? fullName : userId;
                return Text(
                  'Customer: $displayName',
                  style: AppTextStyles.cardMeta,
                );
              },
            ),
          SizedBox(height: 4.h),
          Text(
            'Cancelled by: $cancelledBy'
            '${cancelledByRole.isNotEmpty ? ' ($cancelledByRole)' : ''}',
            style: AppTextStyles.cardMeta,
          ),
          SizedBox(height: 4.h),
          Text(
            'Cancelled at: ${_formatTimestamp(cancelledAt)}',
            style: AppTextStyles.cardMeta,
          ),
          SizedBox(height: 4.h),
          Text(
            'Refund status: $refundLabel',
            style: AppTextStyles.cardMeta.copyWith(
              fontWeight: FontWeight.w600,
              color: refundLabel == 'Refunded'
                  ? const Color(0xFF20C997)
                  : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: disabledChecked
                      ? null
                      : () => _updateRefundStatus(context, 'checked'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: const Text('Mark checked'),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: disabledRefunded
                      ? null
                      : () => _updateRefundStatus(context, 'refunded'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: const Text('Mark refunded'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
