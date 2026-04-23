import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/payment_amount_utils.dart';
import 'package:jood/core/widgets/currency_amount_text.dart';
import 'package:jood/features/admin/presentation/cubit/admin_overview_cubit.dart';
import 'package:jood/features/admin/presentation/cubit/admin_overview_state.dart';
import 'package:jood/features/admin/presentation/web/admin_web_navigation.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_metric_card.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_panel.dart';
import 'package:jood/features/bookings/domain/entities/booking_entity.dart';
import 'package:jood/features/offers/domain/entities/offer_entity.dart';
import 'package:jood/core/di/service_locator.dart';

class AdminWebOverviewPage extends StatefulWidget {
  const AdminWebOverviewPage({super.key, required this.onSelectSection});

  final AdminWebSectionSelector onSelectSection;

  @override
  State<AdminWebOverviewPage> createState() => _AdminWebOverviewPageState();
}

class _AdminWebOverviewPageState extends State<AdminWebOverviewPage> {
  late final AdminOverviewCubit _cubit;
  AdminWebTimeFilter _selectedTimeFilter = AdminWebTimeFilter.allTime;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<AdminOverviewCubit>()..load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _refresh() {
    return _cubit.load();
  }

  List<T> _filterByTimeWindow<T>(
    List<T> items,
    DateTime Function(T item) getDate,
  ) {
    final now = DateTime.now();
    return items
        .where((item) => _selectedTimeFilter.includes(getDate(item), now: now))
        .toList(growable: false);
  }

  Map<String, int> _buildStatusCounts(List<BookingEntity> bookings) {
    final counts = <String, int>{};
    for (final booking in bookings) {
      final status = booking.status.trim().toLowerCase();
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  double _calculateRevenue(List<BookingEntity> bookings) {
    var totalRevenue = 0.0;
    for (final booking in bookings) {
      final status = booking.status.trim().toLowerCase();
      if (status == 'cancelled' || status == 'failed') {
        continue;
      }
      totalRevenue += booking.total;
    }
    return totalRevenue;
  }

  Map<String, int> _buildOfferCategoryCounts(List<OfferEntity> offers) {
    final counts = <String, int>{};
    for (final offer in offers) {
      final category = offer.bookingCategory.trim().isEmpty
          ? 'restaurant'
          : offer.bookingCategory.trim();
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts;
  }

  String _windowDescription() {
    return _selectedTimeFilter.describeWindow();
  }

  void _openBookings({String? status}) {
    widget.onSelectSection(
      AdminWebSection.bookings,
      request: AdminWebSectionRequest(
        timeFilter: _selectedTimeFilter,
        bookingStatus: _normalizeFilterValue(status),
      ),
    );
  }

  void _openPayments({String? paymentState}) {
    widget.onSelectSection(
      AdminWebSection.payments,
      request: AdminWebSectionRequest(
        timeFilter: _selectedTimeFilter,
        paymentState: _normalizeFilterValue(paymentState),
      ),
    );
  }

  String? _normalizeFilterValue(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'all') return null;
    return normalized;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<AdminOverviewCubit, AdminOverviewState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: Builder(
              builder: (context) {
                if (state.status == AdminOverviewStatus.loading &&
                    state.data.bookings.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == AdminOverviewStatus.failure) {
                  return ListView(
                    children: [
                      AdminWebPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Failed to load dashboard',
                              style: AppTextStyles.cardTitle,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              state.errorMessage ?? 'Unknown error',
                              style: AppTextStyles.cardMeta.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 14.h),
                            ElevatedButton.icon(
                              onPressed: _refresh,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Try again'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                final data = state.data;
                final windowBookings = _filterByTimeWindow(
                  data.bookings,
                  (booking) => booking.createdAt,
                );
                final windowOffers = _filterByTimeWindow(
                  data.offers,
                  (offer) => offer.createdAt,
                );
                final windowRestaurants = _filterByTimeWindow(
                  data.restaurants,
                  (restaurant) => restaurant.createdAt,
                );
                final windowStatusCounts = _buildStatusCounts(windowBookings);
                final windowRevenue = _calculateRevenue(windowBookings);
                final windowOfferCategoryCounts = _buildOfferCategoryCounts(
                  windowOffers,
                );
                final activeRestaurantsCount = data.restaurants
                    .where((item) => item.isActive)
                    .length;

                return ListView(
                  children: [
                    _OverviewHeader(
                      bookingsCount: windowBookings.length,
                      timeFilter: _selectedTimeFilter,
                      onTimeFilterChanged: (value) {
                        setState(() => _selectedTimeFilter = value);
                      },
                      onRefresh: _refresh,
                      onOpenRestaurants: () =>
                          widget.onSelectSection(AdminWebSection.restaurants),
                      onOpenBuffet: () =>
                          widget.onSelectSection(AdminWebSection.buffet),
                      onOpenSetMenu: () =>
                          widget.onSelectSection(AdminWebSection.setMenu),
                      onOpenCombo: () =>
                          widget.onSelectSection(AdminWebSection.combo),
                      onOpenAttractions: () =>
                          widget.onSelectSection(AdminWebSection.attractions),
                      onOpenOffers: () =>
                          widget.onSelectSection(AdminWebSection.offers),
                      onOpenBookings: () => _openBookings(),
                      onOpenPayments: () => _openPayments(),
                      onOpenRefunds: () =>
                          widget.onSelectSection(AdminWebSection.refunds),
                    ),
                    SizedBox(height: 20.h),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final spacing = 16.w;
                        final availableWidth = constraints.maxWidth;
                        final useExpandedRow = availableWidth >= 1180;
                        final compactCardWidth = availableWidth < 700
                            ? 260.0
                            : 280.0;
                        final metricCards = [
                          AdminWebMetricCard(
                            title: 'Total bookings',
                            value: '${windowBookings.length}',
                            icon: Icons.receipt_long_outlined,
                            iconColor: AppColors.primary,
                            caption:
                                '${windowStatusCounts['cancelled'] ?? 0} cancelled in ${_windowDescription()}',
                            onTap: () => _openBookings(),
                          ),
                          AdminWebMetricCard(
                            title: 'Gross revenue',
                            value: _formatMoney(windowRevenue),
                            icon: Icons.payments_outlined,
                            iconColor: const Color(0xFF0E9F6E),
                            caption:
                                'Collected totals in ${_windowDescription()}',
                            onTap: () => _openPayments(paymentState: 'paid'),
                          ),
                          AdminWebMetricCard(
                            title: 'Active restaurants',
                            value: '$activeRestaurantsCount',
                            icon: Icons.storefront_outlined,
                            iconColor: const Color(0xFF2563EB),
                            caption:
                                _selectedTimeFilter ==
                                    AdminWebTimeFilter.allTime
                                ? '${data.restaurants.length} total venues'
                                : '${windowRestaurants.length} added in ${_windowDescription()}',
                            onTap: () => widget.onSelectSection(
                              AdminWebSection.restaurants,
                            ),
                          ),
                          AdminWebMetricCard(
                            title: 'Users',
                            value: '${data.users.length}',
                            icon: Icons.people_outline,
                            iconColor: const Color(0xFFF59E0B),
                            caption:
                                _selectedTimeFilter ==
                                    AdminWebTimeFilter.allTime
                                ? 'Platform access directory'
                                : '${windowOffers.length} offers created in ${_windowDescription()}',
                            onTap: () =>
                                widget.onSelectSection(AdminWebSection.users),
                          ),
                        ];

                        if (useExpandedRow) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (
                                var index = 0;
                                index < metricCards.length;
                                index++
                              ) ...[
                                Expanded(child: metricCards[index]),
                                if (index != metricCards.length - 1)
                                  SizedBox(width: spacing),
                              ],
                            ],
                          );
                        }

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (
                                var index = 0;
                                index < metricCards.length;
                                index++
                              ) ...[
                                SizedBox(
                                  width: compactCardWidth,
                                  child: metricCards[index],
                                ),
                                if (index != metricCards.length - 1)
                                  SizedBox(width: spacing),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20.h),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final stacked = constraints.maxWidth < 1180;
                        if (stacked) {
                          return Column(
                            children: [
                              _OfferMixPanel(
                                categoryCounts: windowOfferCategoryCounts,
                                timeFilter: _selectedTimeFilter,
                              ),
                              SizedBox(height: 16.h),
                              _BookingStatusPanel(
                                statusCounts: windowStatusCounts,
                                timeFilter: _selectedTimeFilter,
                                onStatusSelected: (status) =>
                                    _openBookings(status: status),
                              ),
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _OfferMixPanel(
                                categoryCounts: windowOfferCategoryCounts,
                                timeFilter: _selectedTimeFilter,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: _BookingStatusPanel(
                                statusCounts: windowStatusCounts,
                                timeFilter: _selectedTimeFilter,
                                onStatusSelected: (status) =>
                                    _openBookings(status: status),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 20.h),
                    _RecentBookingsPanel(
                      bookings: windowBookings.take(6).toList(),
                      timeFilter: _selectedTimeFilter,
                      onViewAll: () => _openBookings(),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({
    required this.bookingsCount,
    required this.timeFilter,
    required this.onTimeFilterChanged,
    required this.onRefresh,
    required this.onOpenRestaurants,
    required this.onOpenBuffet,
    required this.onOpenSetMenu,
    required this.onOpenCombo,
    required this.onOpenAttractions,
    required this.onOpenOffers,
    required this.onOpenBookings,
    required this.onOpenPayments,
    required this.onOpenRefunds,
  });

  final int bookingsCount;
  final AdminWebTimeFilter timeFilter;
  final ValueChanged<AdminWebTimeFilter> onTimeFilterChanged;
  final VoidCallback onRefresh;
  final VoidCallback onOpenRestaurants;
  final VoidCallback onOpenBuffet;
  final VoidCallback onOpenSetMenu;
  final VoidCallback onOpenCombo;
  final VoidCallback onOpenAttractions;
  final VoidCallback onOpenOffers;
  final VoidCallback onOpenBookings;
  final VoidCallback onOpenPayments;
  final VoidCallback onOpenRefunds;

  @override
  Widget build(BuildContext context) {
    return AdminWebPanel(
      color: const Color(0xFF111827),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 920;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Operations snapshot',
                style: AppTextStyles.cardTitle.copyWith(
                  color: Colors.white,
                  fontSize: 26.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Track bookings, inventory, and team activity from one responsive admin control center.',
                style: AppTextStyles.cardMeta.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'Time window',
                style: AppTextStyles.cardMeta.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  for (final option in AdminWebTimeFilter.values)
                    _HeaderTimeChip(
                      label: option.shortLabel,
                      selected: option == timeFilter,
                      onTap: () => onTimeFilterChanged(option),
                    ),
                ],
              ),
              SizedBox(height: 20.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  _HeaderActionChip(
                    icon: Icons.storefront_outlined,
                    label: 'Restaurants',
                    onTap: onOpenRestaurants,
                  ),
                  _HeaderActionChip(
                    icon: Icons.restaurant_menu_outlined,
                    label: 'Buffet',
                    onTap: onOpenBuffet,
                  ),
                  _HeaderActionChip(
                    icon: Icons.menu_book_outlined,
                    label: 'Set Menu',
                    onTap: onOpenSetMenu,
                  ),
                  _HeaderActionChip(
                    icon: Icons.fastfood_rounded,
                    label: 'Combo',
                    onTap: onOpenCombo,
                  ),
                  _HeaderActionChip(
                    icon: Icons.local_activity_outlined,
                    label: 'Attractions',
                    onTap: onOpenAttractions,
                  ),
                  _HeaderActionChip(
                    icon: Icons.local_offer_outlined,
                    label: 'Offers',
                    onTap: onOpenOffers,
                  ),
                  _HeaderActionChip(
                    icon: Icons.receipt_long_outlined,
                    label: 'Bookings',
                    onTap: onOpenBookings,
                  ),
                  _HeaderActionChip(
                    icon: Icons.credit_card_outlined,
                    label: 'Payments',
                    onTap: onOpenPayments,
                  ),
                  _HeaderActionChip(
                    icon: Icons.replay_circle_filled_outlined,
                    label: 'Refunds',
                    onTap: onOpenRefunds,
                  ),
                ],
              ),
            ],
          );

          final summary = Container(
            width: stacked ? double.infinity : 220.w,
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live activity',
                  style: AppTextStyles.cardMeta.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  '$bookingsCount',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: Colors.white,
                    fontSize: 34.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  timeFilter == AdminWebTimeFilter.allTime
                      ? 'bookings tracked'
                      : 'bookings in ${timeFilter.label.toLowerCase()}',
                  style: AppTextStyles.cardMeta.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                SizedBox(height: 14.h),
                OutlinedButton.icon(
                  onPressed: onRefresh,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                SizedBox(height: 16.h),
                summary,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: content),
              SizedBox(width: 24.w),
              summary,
            ],
          );
        },
      ),
    );
  }
}

class _HeaderTimeChip extends StatelessWidget {
  const _HeaderTimeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(999.r);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.22)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: borderRadius,
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.42)
                  : Colors.white.withValues(alpha: 0.14),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.cardMeta.copyWith(
              color: Colors.white.withValues(alpha: 0.96),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderActionChip extends StatelessWidget {
  const _HeaderActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(999.r);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: borderRadius,
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Icon(icon, color: AppColors.primary, size: 16.sp),
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: AppTextStyles.cardMeta.copyWith(
                  color: Colors.white.withValues(alpha: 0.96),
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferMixPanel extends StatelessWidget {
  const _OfferMixPanel({
    required this.categoryCounts,
    required this.timeFilter,
  });

  final Map<String, int> categoryCounts;
  final AdminWebTimeFilter timeFilter;

  @override
  Widget build(BuildContext context) {
    final total = categoryCounts.values.fold<int>(
      0,
      (accumulated, item) => accumulated + item,
    );
    final entries = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return AdminWebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Offer mix', style: AppTextStyles.cardTitle),
          SizedBox(height: 6.h),
          Text(
            timeFilter == AdminWebTimeFilter.allTime
                ? 'Distribution of active inventory across booking categories.'
                : 'Distribution of offers created in ${timeFilter.label.toLowerCase()}.',
            style: AppTextStyles.cardMeta.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 18.h),
          if (entries.isEmpty)
            Text('No offers available yet.', style: AppTextStyles.cardMeta)
          else
            for (final entry in entries) ...[
              _RatioRow(
                label: entry.key,
                count: entry.value,
                ratio: total == 0 ? 0 : entry.value / total,
              ),
              SizedBox(height: 12.h),
            ],
        ],
      ),
    );
  }
}

class _BookingStatusPanel extends StatelessWidget {
  const _BookingStatusPanel({
    required this.statusCounts,
    required this.timeFilter,
    required this.onStatusSelected,
  });

  final Map<String, int> statusCounts;
  final AdminWebTimeFilter timeFilter;
  final ValueChanged<String> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    final total = statusCounts.values.fold<int>(
      0,
      (accumulated, item) => accumulated + item,
    );
    final entries = statusCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return AdminWebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking status', style: AppTextStyles.cardTitle),
          SizedBox(height: 6.h),
          Text(
            timeFilter == AdminWebTimeFilter.allTime
                ? 'Operational breakdown of current booking outcomes.'
                : 'Operational breakdown of bookings created in ${timeFilter.label.toLowerCase()}.',
            style: AppTextStyles.cardMeta.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 18.h),
          if (entries.isEmpty)
            Text('No bookings available yet.', style: AppTextStyles.cardMeta)
          else
            for (final entry in entries) ...[
              _RatioRow(
                label: entry.key,
                count: entry.value,
                ratio: total == 0 ? 0 : entry.value / total,
                onTap: () => onStatusSelected(entry.key),
              ),
              SizedBox(height: 12.h),
            ],
        ],
      ),
    );
  }
}

class _RatioRow extends StatelessWidget {
  const _RatioRow({
    required this.label,
    required this.count,
    required this.ratio,
    this.onTap,
  });

  final String label;
  final int count;
  final double ratio;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _titleCase(label),
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 14.sp),
              ),
            ),
            Text(
              '$count',
              style: AppTextStyles.cardMeta.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(99.r),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 10.h,
            backgroundColor: const Color(0xFFE9EEF5),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
          child: content,
        ),
      ),
    );
  }
}

class _RecentBookingsPanel extends StatelessWidget {
  const _RecentBookingsPanel({
    required this.bookings,
    required this.timeFilter,
    required this.onViewAll,
  });

  final List<BookingEntity> bookings;
  final AdminWebTimeFilter timeFilter;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d, yyyy - HH:mm');
    return AdminWebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Recent bookings', style: AppTextStyles.cardTitle),
              ),
              TextButton(onPressed: onViewAll, child: const Text('View all')),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            timeFilter == AdminWebTimeFilter.allTime
                ? 'Latest booking activity across the platform.'
                : 'Latest booking activity from ${timeFilter.label.toLowerCase()}.',
            style: AppTextStyles.cardMeta.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 18.h),
          if (bookings.isEmpty)
            Text('No bookings available yet.', style: AppTextStyles.cardMeta)
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 46.h,
                dataRowMinHeight: 52.h,
                dataRowMaxHeight: 56.h,
                columns: const [
                  DataColumn(label: Text('Code')),
                  DataColumn(label: Text('Venue')),
                  DataColumn(label: Text('Offer')),
                  DataColumn(label: Text('Guests')),
                  DataColumn(label: Text('Total')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Created')),
                ],
                rows: bookings
                    .map(
                      (booking) => DataRow(
                        cells: [
                          DataCell(Text(booking.bookingCode)),
                          DataCell(
                            Text(
                              (booking.restaurantNameSnapshot ?? '')
                                      .trim()
                                      .isEmpty
                                  ? booking.restaurantId
                                  : booking.restaurantNameSnapshot!,
                            ),
                          ),
                          DataCell(
                            Text(
                              (booking.offerTitleSnapshot ?? '').trim().isEmpty
                                  ? booking.offerId
                                  : booking.offerTitleSnapshot!,
                            ),
                          ),
                          DataCell(
                            Text('${booking.adults + booking.children}'),
                          ),
                          DataCell(
                            CurrencyAmountInlineText(
                              text: formatCurrency(
                                booking.currency,
                                booking.total,
                              ),
                            ),
                          ),
                          DataCell(_StatusBadge(status: booking.status)),
                          DataCell(Text(formatter.format(booking.createdAt))),
                        ],
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    Color color;
    switch (normalized) {
      case 'cancelled':
        color = const Color(0xFFD14343);
        break;
      case 'paid':
      case 'confirmed':
        color = const Color(0xFF0E9F6E);
        break;
      case 'pending':
        color = const Color(0xFFF59E0B);
        break;
      default:
        color = AppColors.primary;
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        _titleCase(status),
        style: AppTextStyles.cardMeta.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _formatMoney(double amount) {
  return formatCurrency('OMR', amount);
}

String _titleCase(String value) {
  final words = value
      .replaceAll('_', ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
  if (words.isEmpty) return '-';
  return words
      .map(
        (word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}
