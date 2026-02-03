import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';

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
                    final data = docs[index].data();
                    return Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: _OrderCard(
                        bookingCode: (data['bookingCode'] as String?) ?? '',
                        qrPayload: (data['qrPayload'] as String?) ?? '',
                        restaurantId: (data['restaurantId'] as String?) ?? '',
                        date: (data['date'] as String?) ?? '',
                        startTime: (data['startTime'] as String?) ?? '',
                        status: (data['status'] as String?) ?? 'paid',
                        total: (data['total'] as num?)?.toDouble() ?? 0,
                        createdAt: data['createdAt'],
                      ),
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
  const _OrderCard({
    required this.bookingCode,
    required this.qrPayload,
    required this.restaurantId,
    required this.date,
    required this.startTime,
    required this.status,
    required this.total,
    required this.createdAt,
  });

  final String bookingCode;
  final String qrPayload;
  final String restaurantId;
  final String date;
  final String startTime;
  final String status;
  final double total;
  final dynamic createdAt;

  Color _statusColor(String statusValue) {
    final normalized = statusValue.toLowerCase();
    if (normalized == 'completed') return const Color(0xFF5C7CFA);
    if (normalized == 'paid' || normalized == 'confirmed')
      return const Color(0xFF20C997);
    return const Color(0xFFFA5252);
  }

  String _statusLabel(String statusValue) {
    if (statusValue.isEmpty) return 'Unknown';
    return statusValue[0].toUpperCase() +
        statusValue.substring(1).toLowerCase();
  }

  String _formattedDate() {
    if (date.isNotEmpty) return date;
    if (createdAt is Timestamp) {
      return DateFormat(
        'MMM d, yyyy',
      ).format((createdAt as Timestamp).toDate());
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    if (restaurantId.isEmpty) {
      return _buildCard(
        context: context,
        restaurantName: 'Restaurant',
        restaurantImageUrl: '',
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .snapshots(),
      builder: (context, snapshot) {
        final restaurantData = snapshot.data?.data();
        final restaurantName =
            (restaurantData?['name'] as String?)?.trim().isNotEmpty == true
            ? (restaurantData?['name'] as String)
            : restaurantId;
        final restaurantImageUrl =
            (restaurantData?['coverImageUrl'] as String?) ?? '';

        return _buildCard(
          context: context,
          restaurantName: restaurantName,
          restaurantImageUrl: restaurantImageUrl,
        );
      },
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String restaurantName,
    required String restaurantImageUrl,
  }) {
    final badgeColor = _statusColor(status);
    return Container(
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
                    Text('Code: $bookingCode', style: AppTextStyles.cardMeta),
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
                  _statusLabel(status),
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
            '${_formattedDate()}  $startTime',
            style: AppTextStyles.cardMeta,
          ),
          SizedBox(height: 4.h),
          Text(
            'Total: ${total.toStringAsFixed(2)}',
            style: AppTextStyles.cardPrice,
          ),
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: qrPayload.isEmpty
                  ? null
                  : () => _showQrSheet(context, qrPayload, bookingCode),
              icon: const Icon(Icons.qr_code),
              label: const Text('View QR'),
            ),
          ),
        ],
      ),
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
