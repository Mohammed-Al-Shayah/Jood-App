import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/app_strings.dart';
import 'package:jood/core/utils/extensions.dart';
import 'package:jood/core/utils/guest_pricing_utils.dart';
import 'package:jood/core/utils/payment_amount_utils.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/core/widgets/currency_amount_text.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../domain/entities/booking_entity.dart';
import '../../domain/services/booking_order_policy.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';

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
    return BlocProvider(
      create: (_) => getIt<OrdersCubit>()..initialize(),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatelessWidget {
  const _OrdersView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state.status == OrdersStatus.initial ||
              state.status == OrdersStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == OrdersStatus.unauthenticated) {
            return Center(
              child: Text(state.errorMessage ?? AppStrings.pleaseLoginFirst),
            );
          }
          if (state.status == OrdersStatus.failure) {
            return Center(
              child: Text(state.errorMessage ?? AppStrings.failedToLoadOrders),
            );
          }
          if (state.orders.isEmpty) {
            return const _OrdersEmptyState();
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.orders,
                        style: AppTextStyles.headingMedium,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        AppStrings.bookingsCount(state.orders.length),
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
                  itemCount: state.orders.length,
                  itemBuilder: (context, index) {
                    final order = state.orders[index];
                    final venue = _resolveVenueDetails(order, state);
                    return Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: _OrderCard(
                        order: order,
                        restaurantName: venue.name,
                        restaurantImageUrl: venue.coverImageUrl,
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

  OrderVenueDetails _resolveVenueDetails(
    BookingEntity order,
    OrdersState state,
  ) {
    final snapshotName = (order.restaurantNameSnapshot ?? '').trim();
    final snapshotImage = (order.coverImageUrlSnapshot ?? '').trim();
    final hydratedVenue = state.venueDetailsByKey[_venueKey(order)];

    final displayName = snapshotName.isNotEmpty
        ? snapshotName
        : (hydratedVenue?.name.trim().isNotEmpty == true
              ? hydratedVenue!.name
              : AppStrings.booking);
    final displayImage = snapshotImage.isNotEmpty
        ? snapshotImage
        : (hydratedVenue?.coverImageUrl ?? '');

    return OrderVenueDetails(name: displayName, coverImageUrl: displayImage);
  }

  String _venueKey(BookingEntity order) {
    final type = (order.bookableType ?? '').trim().toLowerCase();
    final collection = type == 'attraction' ? 'attractions' : 'restaurants';
    return '$collection:${order.restaurantId}';
  }
}

class _OrdersEmptyState extends StatelessWidget {
  const _OrdersEmptyState();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.orders, style: AppTextStyles.headingMedium),
            SizedBox(height: 4.h),
            Text(
              AppStrings.yourBookingsAndQrPassesWillAppearHere,
              style: AppTextStyles.cardMeta.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(22.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28.r),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFF4FFFD),
                        AppColors.primary.withValues(alpha: 0.12),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.14),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 26.r,
                        offset: Offset(0, 14.h),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 86.r,
                        height: 86.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.18),
                              AppColors.primary.withValues(alpha: 0.06),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.primaryDark,
                          size: 38.sp,
                        ),
                      ),
                      SizedBox(height: 22.h),
                      Text(
                        AppStrings.noOrdersYet,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headingMedium.copyWith(
                          fontSize: 22.sp,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        AppStrings.ordersEmptySubtitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          _OrdersEmptyChip(
                            icon: Icons.restaurant_outlined,
                            label: AppStrings.buffet,
                          ),
                          _OrdersEmptyChip(
                            icon: Icons.menu_book_outlined,
                            label: AppStrings.setMenu,
                          ),
                          _OrdersEmptyChip(
                            icon: Icons.local_activity_outlined,
                            label: AppStrings.attractions,
                          ),
                        ],
                      ),
                      SizedBox(height: 22.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              context.pushNamedAndRemoveAll(Routes.homeScreen),
                          icon: const Icon(Icons.explore_outlined),
                          label: Text(AppStrings.exploreExperiences),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersEmptyChip extends StatelessWidget {
  const _OrdersEmptyChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: AppColors.primaryDark),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.cardMeta.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.restaurantName,
    required this.restaurantImageUrl,
  });

  final BookingEntity order;
  final String restaurantName;
  final String restaurantImageUrl;

  Color _statusColor(String statusValue) {
    final normalized = statusValue.toLowerCase();
    if (normalized == 'completed') return const Color(0xFF5C7CFA);
    if (normalized == 'paid' || normalized == 'confirmed') {
      return const Color(0xFF20C997);
    }
    if (BookingOrderPolicy.isCancelledStatus(normalized)) {
      return const Color(0xFF868E96);
    }
    return const Color(0xFFFA5252);
  }

  String _statusLabel(String statusValue) {
    return AppStrings.bookingStatusLabel(statusValue);
  }

  String _formattedDate() {
    if (order.date.trim().isNotEmpty) return order.date;
    return DateFormat('MMM d, yyyy').format(order.createdAt);
  }

  @override
  Widget build(BuildContext context) {
    return _buildCard(
      context: context,
      restaurantName: restaurantName,
      restaurantImageUrl: restaurantImageUrl,
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String restaurantName,
    required String restaurantImageUrl,
  }) {
    final badgeColor = _statusColor(order.status);
    final showQr =
        order.qrPayload.isNotEmpty &&
        BookingOrderPolicy.canShowQr(order.status) &&
        !BookingOrderPolicy.isCompletedStatus(order.status) &&
        !BookingOrderPolicy.isCancelledStatus(order.status);
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
                        AppStrings.bookingCodeValue(order.bookingCode),
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
            CurrencyAmountInlineText(
              text: AppStrings.totalValue(
                formatCurrency(order.currency, order.total),
              ),
              style: AppTextStyles.cardPrice,
            ),
            SizedBox(height: 10.h),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: showQr
                  ? TextButton.icon(
                      onPressed: () => _showQrSheet(
                        context,
                        order.qrPayload,
                        order.bookingCode,
                      ),
                      icon: const Icon(Icons.qr_code),
                      label: Text(AppStrings.viewQr),
                    )
                  : const SizedBox.shrink(),
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
    final showCancel =
        !BookingOrderPolicy.isCancelledStatus(order.status) &&
        !BookingOrderPolicy.isCompletedStatus(order.status) &&
        BookingOrderPolicy.isCancellationAllowed(
          date: order.date,
          startTime: order.startTime,
          endTime: order.endTime,
        );
    final showQr =
        order.qrPayload.isNotEmpty &&
        BookingOrderPolicy.canShowQr(order.status);
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20.w,
            16.h,
            20.w,
            24.h + viewInsetsBottom,
          ),
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
              if ((order.offerTitleSnapshot ?? '').isNotEmpty)
                Text(
                  order.offerTitleSnapshot!,
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 14.sp),
                ),
              if ((order.offerTitleSnapshot ?? '').isNotEmpty)
                SizedBox(height: 6.h),
              Text(
                AppStrings.bookingCodeValue(order.bookingCode),
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
              CurrencyAmountInlineText(
                text: AppStrings.totalValue(
                  formatCurrency(order.currency, order.total),
                ),
                style: AppTextStyles.cardPrice.copyWith(
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                AppStrings.statusValue(_statusLabel(order.status)),
                style: AppTextStyles.cardMeta.copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10.h),
              if (order.usesUnifiedGuestCount)
                _DetailRow(
                  label: selectionCountTitle(
                    bookingCategory: order.bookingCategory ?? '',
                    guestPricingMode: order.guestPricingMode ?? '',
                    bookableType: order.bookableType ?? '',
                  ),
                  value:
                      '${order.adults + order.children} x ${formatCurrency(order.currency, order.unitPriceAdult)}',
                )
              else ...[
                _DetailRow(
                  label: AppStrings.adults,
                  value:
                      '${order.adults} x ${formatCurrency(order.currency, order.unitPriceAdult)}',
                ),
                _DetailRow(
                  label: AppStrings.children,
                  value:
                      '${order.children} x ${formatCurrency(order.currency, order.unitPriceChild)}',
                ),
              ],
              _DetailRow(
                label: AppStrings.subtotal,
                value: formatCurrency(order.currency, order.subtotal),
              ),
              _DetailRow(
                label: AppStrings.vat,
                value: formatCurrency(order.currency, order.tax),
              ),
              SizedBox(height: 14.h),
              if (showCancel) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleCancel(context),
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(AppStrings.cancelBooking),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
              ],
              if (showQr)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showQrSheet(context, order.qrPayload, order.bookingCode);
                    },
                    icon: const Icon(Icons.qr_code),
                    label: Text(AppStrings.viewQr),
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

  Future<void> _handleCancel(BuildContext context) async {
    if (!BookingOrderPolicy.isCancellationAllowed(
      date: order.date,
      startTime: order.startTime,
      endTime: order.endTime,
    )) {
      showAppSnackBar(
        context,
        AppStrings.cancellationWindowEnded,
        type: SnackBarType.info,
        fromTop: true,
      );
      return;
    }

    showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    String? errorMessage;
    try {
      errorMessage = await context.read<OrdersCubit>().cancelBooking(order);
    } catch (_) {
      errorMessage = AppStrings.failedToCancelBooking;
    } finally {
      if (context.mounted) {
        final rootNav = Navigator.of(context, rootNavigator: true);
        if (rootNav.canPop()) {
          rootNav.pop();
        }
      }
    }

    if (!context.mounted) return;
    if (errorMessage == null) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      showAppSnackBar(
        context,
        AppStrings.bookingCancelledSuccessfully,
        type: SnackBarType.success,
        fromTop: true,
      );
      return;
    }

    showAppSnackBar(
      context,
      errorMessage,
      type: SnackBarType.error,
      fromTop: true,
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
              Text(AppStrings.bookingQr, style: AppTextStyles.headingMedium),
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
          CurrencyAmountInlineText(
            text: value,
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
