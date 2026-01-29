import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    final orders = [
      const _OrderItem(
        title: 'The Gran...',
        date: 'Jan 28, 2024',
        time: '07:00 PM',
        price: '2147',
        status: _OrderStatus.confirmed,
        actionLabel: 'View QR',
        guestsLabel: '2 Adults + 1 Child',
        imageUrl:
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80',
      ),
      const _OrderItem(
        title: 'Spice Garden',
        date: 'Jan 20, 2024',
        time: '12:00 PM',
        price: '1996',
        status: _OrderStatus.used,
        actionLabel: 'View Details',
        imageUrl:
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80',
      ),
      const _OrderItem(
        title: 'Ocean Blue',
        date: 'Jan 15, 2024',
        time: '09:00 AM',
        price: '1896',
        status: _OrderStatus.expired,
        actionLabel: 'View Details',
        imageUrl:
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80',
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Orders', style: AppTextStyles.headingMedium),
            SizedBox(height: 4.h),
            Text('3 bookings', style: AppTextStyles.cardMeta),
            SizedBox(height: 16.h),
            ...orders.map(
              (order) => Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: _OrderCard(order: order),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _OrderStatus { confirmed, used, expired }

class _OrderItem {
  const _OrderItem({
    required this.title,
    required this.date,
    required this.time,
    required this.price,
    required this.status,
    required this.actionLabel,
    required this.imageUrl,
    this.guestsLabel,
  });

  final String title;
  final String date;
  final String time;
  final String price;
  final _OrderStatus status;
  final String actionLabel;
  final String imageUrl;
  final String? guestsLabel;
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final _OrderItem order;

  Color _statusColor(_OrderStatus status) {
    switch (status) {
      case _OrderStatus.confirmed:
        return const Color(0xFF20C997);
      case _OrderStatus.used:
        return const Color(0xFF5C7CFA);
      case _OrderStatus.expired:
        return const Color(0xFFFA5252);
    }
  }

  String _statusLabel(_OrderStatus status) {
    switch (status) {
      case _OrderStatus.confirmed:
        return 'Confirmed';
      case _OrderStatus.used:
        return 'Used';
      case _OrderStatus.expired:
        return 'Expired';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: order.imageUrl,
                  width: 72.w,
                  height: 72.w,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => _ImageFallback(size: 72.w),
                  errorWidget: (_, _, _) => _ImageFallback(size: 72.w),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            order.title,
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
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            _statusLabel(order.status),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14),
                        SizedBox(width: 6.w),
                        Text(order.date, style: AppTextStyles.cardMeta),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14),
                        SizedBox(width: 6.w),
                        Text(order.time, style: AppTextStyles.cardMeta),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('৳${order.price}', style: AppTextStyles.cardPrice),
                        Text(
                          order.actionLabel,
                          style: AppTextStyles.cardMeta.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (order.guestsLabel != null) ...[
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFEFFAF6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                order.guestsLabel!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: const Icon(Icons.image, color: AppColors.textMuted),
    );
  }
}
