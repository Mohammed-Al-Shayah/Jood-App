import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/extensions.dart';
import 'package:jood/core/utils/payment_amount_utils.dart';
import 'package:jood/features/admin/presentation/cubit/admin_orders_cubit.dart';
import 'package:jood/features/admin/presentation/cubit/admin_orders_state.dart';
import 'package:jood/features/admin/presentation/widgets/admin_section_card.dart';
import 'package:jood/features/admin/presentation/widgets/admin_shell.dart';
import 'package:jood/features/bookings/domain/entities/booking_entity.dart';
import 'package:jood/features/bookings/domain/usecases/watch_all_bookings_usecase.dart';
import 'package:jood/features/restaurants/domain/entities/restaurant_entity.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminOrdersCubit>()..load(),
      child: BlocBuilder<AdminOrdersCubit, AdminOrdersState>(
        builder: (context, state) {
          return AdminShell(
            title: 'Orders',
            body: Column(
              children: [
                _FiltersCard(state: state),
                SizedBox(height: 12.h),
                Expanded(child: _OrdersList(state: state)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FiltersCard extends StatelessWidget {
  const _FiltersCard({required this.state});

  final AdminOrdersState state;

  String _formatRange(DateTimeRange? range) {
    if (range == null) return 'All dates';
    final formatter = DateFormat('MMM d, yyyy');
    final start = formatter.format(range.start);
    final end = formatter.format(range.end);
    return '$start - $end';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AdminOrdersCubit>();
    final isLoading = state.status == AdminOrdersStatus.loading;

    return AdminSectionCard(
      title: 'Filters',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Restaurant', style: AppTextStyles.cardMeta),
          SizedBox(height: 6.h),
          DropdownButtonFormField<String>(
            initialValue: state.selectedRestaurantId.isEmpty
                ? null
                : state.selectedRestaurantId,
            decoration: InputDecoration(
              hintText: 'All restaurants',
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
            items: _buildRestaurantItems(state.restaurants),
            onChanged: isLoading
                ? null
                : (value) => cubit.setRestaurant(value ?? ''),
          ),
          SizedBox(height: 12.h),
          Text('Date range', style: AppTextStyles.cardMeta),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    _formatRange(state.dateRange),
                    style: AppTextStyles.cardMeta.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              ElevatedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final initial =
                      state.dateRange ??
                      DateTimeRange(
                        start: DateTime(now.year, now.month, now.day - 7),
                        end: DateTime(now.year, now.month, now.day),
                      );
                  final range = await showDateRangePicker(
                    context: context,
                    initialDateRange: initial,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(now.year + 1),
                  );
                  if (range != null && context.mounted) {
                    cubit.setDateRange(
                      DateTimeRange(
                        start: DateTime(
                          range.start.year,
                          range.start.month,
                          range.start.day,
                        ),
                        end: DateTime(
                          range.end.year,
                          range.end.month,
                          range.end.day,
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.date_range),
                label: const Text('Pick'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
          if (state.hasFilters) ...[
            SizedBox(height: 10.h),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: cubit.clearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Clear filters'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildRestaurantItems(
    List<RestaurantEntity> restaurants,
  ) {
    if (restaurants.isEmpty) return const [];
    return restaurants
        .map(
          (restaurant) => DropdownMenuItem<String>(
            value: restaurant.id,
            child: Text(restaurant.name),
          ),
        )
        .toList();
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({required this.state});

  final AdminOrdersState state;

  @override
  Widget build(BuildContext context) {
    final stream = getIt<WatchAllBookingsUseCase>()();

    return StreamBuilder<List<BookingEntity>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load orders: ${snapshot.error}',
              style: AppTextStyles.cardMeta,
              textAlign: TextAlign.center,
            ),
          );
        }

        final orders = (snapshot.data ?? const <BookingEntity>[])
            .where((order) => _matchesFilters(order, state))
            .toList(growable: false);

        if (orders.isEmpty) {
          return Center(
            child: Text('No orders found.', style: AppTextStyles.cardMeta),
          );
        }

        final restaurantNames = {
          for (final r in state.restaurants) r.id: r.name,
        };
        final grouped = _groupOrders(orders, restaurantNames);

        return ListView.separated(
          itemCount: grouped.length,
          separatorBuilder: (_, _) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final group = grouped[index];
            return AdminSectionCard(
              title: group.restaurantName,
              child: Column(
                children: [
                  for (var i = 0; i < group.orders.length; i++) ...[
                    _OrderTile(order: group.orders[i]),
                    if (i != group.orders.length - 1) SizedBox(height: 10.h),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool _matchesFilters(BookingEntity order, AdminOrdersState state) {
    final selectedRestaurant = state.selectedRestaurantId.trim();
    if (selectedRestaurant.isNotEmpty &&
        order.restaurantId != selectedRestaurant) {
      return false;
    }
    final range = state.dateRange;
    if (range == null) return true;
    final bookingDate = _parseOrderDate(order);
    if (bookingDate == null) return false;
    return !_isOutsideRange(bookingDate, range);
  }

  DateTime? _parseOrderDate(BookingEntity order) {
    if (order.date.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(order.date.trim());
      if (parsed != null) {
        return DateTime(parsed.year, parsed.month, parsed.day);
      }
    }
    return DateTime(
      order.createdAt.year,
      order.createdAt.month,
      order.createdAt.day,
    );
  }

  bool _isOutsideRange(DateTime date, DateTimeRange range) {
    final start = DateTime(
      range.start.year,
      range.start.month,
      range.start.day,
    );
    final end = DateTime(range.end.year, range.end.month, range.end.day);
    return date.isBefore(start) || date.isAfter(end);
  }

  List<_OrderGroup> _groupOrders(
    List<BookingEntity> orders,
    Map<String, String> restaurantNames,
  ) {
    final Map<String, _OrderGroup> groups = {};
    for (final order in orders) {
      final restaurantId = order.restaurantId.trim();
      final snapshotName = (order.restaurantNameSnapshot ?? '').trim();
      final name = snapshotName.isNotEmpty
          ? snapshotName
          : restaurantNames[restaurantId] ??
                (restaurantId.isNotEmpty ? restaurantId : 'Restaurant');
      final key = restaurantId.isNotEmpty ? restaurantId : name;
      groups.putIfAbsent(key, () => _OrderGroup(restaurantName: name));
      groups[key]!.orders.add(order);
    }
    return groups.values.toList()
      ..sort((a, b) => a.restaurantName.compareTo(b.restaurantName));
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final BookingEntity order;

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'completed') return const Color(0xFF5C7CFA);
    if (normalized == 'paid' || normalized == 'confirmed') {
      return const Color(0xFF20C997);
    }
    if (normalized == 'cancelled' || normalized == 'canceled') {
      return const Color(0xFF868E96);
    }
    return const Color(0xFFFA5252);
  }

  String _statusLabel(String status) {
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  String _displayDate() {
    if (order.date.trim().isNotEmpty) {
      return order.date.toFormattedDate();
    }
    return DateFormat('yyyy-MM-dd').format(order.createdAt);
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _statusColor(order.status);
    final offerTitle = (order.offerTitleSnapshot ?? '').trim();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.iconStroke),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Code: ${order.bookingCode}',
                  style: AppTextStyles.cardMeta.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${_displayDate()}  ${order.startTime}',
                  style: AppTextStyles.cardMeta,
                ),
                if (offerTitle.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    offerTitle,
                    style: AppTextStyles.cardMeta.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCurrency(order.currency, order.total),
                style: AppTextStyles.cardPrice,
              ),
              SizedBox(height: 6.h),
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
        ],
      ),
    );
  }
}

class _OrderGroup {
  _OrderGroup({required this.restaurantName}) : orders = [];

  final String restaurantName;
  final List<BookingEntity> orders;
}
