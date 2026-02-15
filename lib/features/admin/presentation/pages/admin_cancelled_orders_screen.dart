import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/features/admin/presentation/widgets/admin_shell.dart';

class AdminCancelledOrdersScreen extends StatelessWidget {
  const AdminCancelledOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('bookings')
        .where('status', whereIn: const ['cancelled', 'canceled'])
        .snapshots();

    return AdminShell(
      title: 'Cancelled Orders',
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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

          final docs = (snapshot.data?.docs ?? const []).toList()
            ..sort((a, b) {
              final aTime = (a.data()['cancelledAt'] as Timestamp?)?.toDate();
              final bTime = (b.data()['cancelledAt'] as Timestamp?)?.toDate();
              if (aTime == null && bTime == null) return 0;
              if (aTime == null) return 1;
              if (bTime == null) return -1;
              return bTime.compareTo(aTime);
            });
          if (docs.isEmpty) {
            return const Center(child: Text('No cancelled orders yet.'));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              return _CancelledOrderCard(
                bookingId: doc.id,
                restaurantName:
                    (data['restaurantNameSnapshot'] as String?)?.trim() ??
                    (data['restaurantId'] as String? ?? 'Restaurant'),
                bookingCode: (data['bookingCode'] as String?) ?? '',
                date: (data['date'] as String?) ?? '',
                startTime: (data['startTime'] as String?) ?? '',
                total: (data['total'] as num?)?.toDouble() ?? 0,
                currency: (data['currency'] as String?) ?? 'USD',
                userId: (data['userId'] as String?) ?? '',
                cancelledBy: (data['cancelledBy'] as String?) ?? '-',
                cancelledByRole: (data['cancelledByRole'] as String?) ?? '',
                cancelledAt: data['cancelledAt'] as Timestamp?,
                refundStatus: (data['refundStatus'] as String?) ?? 'pending',
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
  final Timestamp? cancelledAt;
  final String refundStatus;

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '-';
    return DateFormat('MMM d, yyyy • h:mm a').format(timestamp.toDate());
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

  Future<void> _updateRefundStatus(
    BuildContext context,
    String status,
  ) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'admin';
    try {
      final payload = <String, dynamic>{
        'refundStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (status == 'checked') {
        payload['refundCheckedAt'] = FieldValue.serverTimestamp();
        payload['refundCheckedBy'] = userId;
      }
      if (status == 'refunded') {
        payload['refundedAt'] = FieldValue.serverTimestamp();
        payload['refundedBy'] = userId;
      }

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .set(payload, SetOptions(merge: true));

      if (context.mounted) {
        showAppSnackBar(
          context,
          'Refund status updated.',
          type: SnackBarType.success,
        );
      }
    } catch (error) {
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
    final disabledChecked = _isChecked(refundStatus) || _isRefunded(refundStatus);
    final disabledRefunded = _isRefunded(refundStatus);
    final userFuture = userId.trim().isEmpty
        ? null
        : FirebaseFirestore.instance.collection('users').doc(userId).get();

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.12),
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
            'Total: $currency ${total.toStringAsFixed(2)}',
            style: AppTextStyles.cardPrice,
          ),
          SizedBox(height: 8.h),
          if (userFuture == null)
            Text('Customer: -', style: AppTextStyles.cardMeta)
          else
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: userFuture,
              builder: (context, snapshot) {
                final data = snapshot.data?.data();
                final fullName = (data?['fullName'] as String?)?.trim();
                final displayName = (fullName != null && fullName.isNotEmpty)
                    ? fullName
                    : userId;
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
