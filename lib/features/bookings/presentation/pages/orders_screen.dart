import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/payment_amount_utils.dart';
import '../models/order_item_view_model.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: const OrdersTab(),
    );
  }
}

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const SafeArea(child: Center(child: Text('Please login first.')));
    }

    final stream = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return SafeArea(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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

          final docs = snapshot.data?.docs ?? const [];
          if (docs.isEmpty) {
            return const Center(child: Text('No orders yet.'));
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Orders', style: AppTextStyles.headingMedium),
                      SizedBox(height: 4.h),
                      Text(
                        '${docs.length} bookings',
                        style: AppTextStyles.cardMeta,
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                sliver: SliverList.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final order = OrderItemViewModel.fromDoc(docs[index]);
                    return Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: _OrderCard(order: order),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderItemViewModel order;

  Color _statusColor(String statusValue) {
    final normalized = statusValue.toLowerCase();
    if (normalized == 'completed') return const Color(0xFF5C7CFA);
    if (normalized == 'paid' || normalized == 'confirmed') {
      return const Color(0xFF20C997);
    }
    return const Color(0xFFFA5252);
  }

  String _statusLabel(String statusValue) {
    if (statusValue.isEmpty) return 'Unknown';
    return statusValue[0].toUpperCase() +
        statusValue.substring(1).toLowerCase();
  }

  String _formattedDate() {
    if (order.date.isNotEmpty) return order.date;
    final createdAt = order.createdAt;
    if (createdAt != null) {
      return DateFormat('MMM d, yyyy').format(createdAt.toDate());
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    if (order.restaurantId.isEmpty) {
      return _buildCard(
        context: context,
        restaurantName: order.restaurantNameSnapshot.isEmpty
            ? 'Restaurant'
            : order.restaurantNameSnapshot,
        restaurantImageUrl: '',
      );
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('restaurants')
          .doc(order.restaurantId)
          .get(),
      builder: (context, snapshot) {
        final restaurant = RestaurantSummaryViewModel.fromDoc(
          data: snapshot.data?.data(),
          fallbackId: order.restaurantId,
        );
        final displayName = order.restaurantNameSnapshot.isNotEmpty
            ? order.restaurantNameSnapshot
            : restaurant.name;

        return _buildCard(
          context: context,
          restaurantName: displayName,
          restaurantImageUrl: restaurant.coverImageUrl,
        );
      },
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String restaurantName,
    required String restaurantImageUrl,
  }) {
    final badgeColor = _statusColor(order.status);
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: () => _showDetailsSheet(
        context,
        restaurantName: restaurantName,
        restaurantImageUrl: restaurantImageUrl,
      ),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 16.r,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _RestaurantImage(url: restaurantImageUrl),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurantName,
                        style: AppTextStyles.sectionTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Code: ${order.bookingCode}',
                        style: AppTextStyles.cardMeta,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    _statusLabel(order.status),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: badgeColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              '${_formattedDate()}  ${order.startTime}',
              style: AppTextStyles.cardMeta,
            ),
            SizedBox(height: 4.h),
            Text(
              'Total: ${formatCurrency(order.currency, order.total)}',
              style: AppTextStyles.cardPrice,
            ),
            SizedBox(height: 10.h),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: order.qrPayload.isEmpty
                    ? null
                    : () => _showQrSheet(
                        context,
                        order.qrPayload,
                        order.bookingCode,
                      ),
                icon: const Icon(Icons.qr_code),
                label: const Text('View QR'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsSheet(
    BuildContext context, {
    required String restaurantName,
    required String restaurantImageUrl,
  }) {
    final badgeColor = _statusColor(order.status);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              Row(
                children: [
                  _RestaurantImage(url: restaurantImageUrl),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      restaurantName,
                      style: AppTextStyles.sectionTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      _statusLabel(order.status),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: badgeColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              if (order.offerTitleSnapshot.isNotEmpty)
                Text(
                  order.offerTitleSnapshot,
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 14.sp),
                ),
              if (order.offerTitleSnapshot.isNotEmpty) SizedBox(height: 6.h),
              Text(
                'Code: ${order.bookingCode}',
                style: AppTextStyles.cardMeta.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                '${_formattedDate()}  ${order.startTime}',
                style: AppTextStyles.cardMeta.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Total: ${formatCurrency(order.currency, order.total)}',
                style: AppTextStyles.cardPrice.copyWith(
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Status: ${_statusLabel(order.status)}',
                style: AppTextStyles.cardMeta.copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10.h),
              _DetailRow(
                label: 'Adults',
                value:
                    '${order.adults} × ${formatCurrency(order.currency, order.unitPriceAdult)}',
              ),
              _DetailRow(
                label: 'Children',
                value:
                    '${order.children} × ${formatCurrency(order.currency, order.unitPriceChild)}',
              ),
              _DetailRow(
                label: 'Subtotal',
                value: formatCurrency(order.currency, order.subtotal),
              ),
              _DetailRow(
                label: 'VAT',
                value: formatCurrency(order.currency, order.tax),
              ),
              SizedBox(height: 14.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: order.qrPayload.isEmpty
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          _showQrSheet(
                            context,
                            order.qrPayload,
                            order.bookingCode,
                          );
                        },
                  icon: const Icon(Icons.qr_code),
                  label: const Text('View QR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQrSheet(BuildContext context, String qrValue, String code) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Booking QR', style: AppTextStyles.headingMedium),
              SizedBox(height: 8.h),
              Text(code, style: AppTextStyles.cardMeta),
              SizedBox(height: 12.h),
              QrImageView(
                data: qrValue,
                size: 220.w,
                backgroundColor: Colors.white,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RestaurantImage extends StatelessWidget {
  const _RestaurantImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: const Icon(Icons.restaurant, color: AppColors.textMuted),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Image.network(
        url,
        width: 48.w,
        height: 48.w,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            width: 48.w,
            height: 48.w,
            color: AppColors.background,
            child: const Icon(Icons.broken_image, color: AppColors.textMuted),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.cardMeta.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.cardMeta.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
