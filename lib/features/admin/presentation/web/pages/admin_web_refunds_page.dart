import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_filter_dropdown_field.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_metric_card.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_panel.dart';
import 'package:jood/features/bookings/domain/entities/booking_entity.dart';
import 'package:jood/features/bookings/domain/usecases/update_booking_refund_status_usecase.dart';
import 'package:jood/features/bookings/domain/usecases/watch_all_bookings_usecase.dart';
import 'package:jood/features/users/domain/usecases/get_users_usecase.dart';

class AdminWebRefundsPage extends StatefulWidget {
  const AdminWebRefundsPage({super.key});

  @override
  State<AdminWebRefundsPage> createState() => _AdminWebRefundsPageState();
}

class _AdminWebRefundsPageState extends State<AdminWebRefundsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _refundFilter = 'all';
  String _venueFilter = 'all';
  _RefundsSort _sortBy = _RefundsSort.cancelledNewest;
  String? _updatingBookingId;
  final Map<String, _RefundCustomerInfo> _customerCache = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> _loadCustomers() async {
    try {
      final users = await getIt<GetUsersUseCase>()();
      if (!mounted) return;
      setState(() {
        for (final user in users) {
          _customerCache[user.id] = _RefundCustomerInfo(
            fullName: user.fullName.trim(),
            phone: user.phone.trim(),
          );
        }
      });
    } catch (_) {
      // Keep fallback values from booking data if the user directory fails.
    }
  }

  List<BookingEntity> _applyFilters(List<BookingEntity> items) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = items
        .where((booking) {
          final refundStatus = _refundStatus(booking);
          final venueName = _venueName(booking).toLowerCase();
          if (_refundFilter != 'all' && refundStatus != _refundFilter) {
            return false;
          }
          if (_venueFilter != 'all' &&
              venueName != _venueFilter.toLowerCase()) {
            return false;
          }
          if (query.isEmpty) return true;
          final customer = _customerCache[booking.userId];
          final haystack = [
            booking.bookingCode,
            _venueName(booking),
            booking.offerTitleSnapshot ?? '',
            booking.userId,
            customer?.fullName ?? '',
            customer?.phone ?? '',
            booking.date,
            booking.startTime,
            booking.status,
          ].join(' ').toLowerCase();
          return haystack.contains(query);
        })
        .toList(growable: false);

    filtered.sort((a, b) {
      switch (_sortBy) {
        case _RefundsSort.cancelledNewest:
          return b.createdAt.compareTo(a.createdAt);
        case _RefundsSort.cancelledOldest:
          return a.createdAt.compareTo(b.createdAt);
        case _RefundsSort.venueAsc:
          return _venueName(
            a,
          ).toLowerCase().compareTo(_venueName(b).toLowerCase());
        case _RefundsSort.venueDesc:
          return _venueName(
            b,
          ).toLowerCase().compareTo(_venueName(a).toLowerCase());
        case _RefundsSort.amountHigh:
          return b.total.compareTo(a.total);
        case _RefundsSort.amountLow:
          return a.total.compareTo(b.total);
      }
    });

    return filtered;
  }

  String _venueName(BookingEntity booking) {
    final snapshot = (booking.restaurantNameSnapshot ?? '').trim();
    if (snapshot.isNotEmpty) return snapshot;
    final fallback = booking.restaurantId.trim();
    return fallback.isEmpty ? '-' : fallback;
  }

  Future<void> _updateRefundStatus(String bookingId, String status) async {
    setState(() {
      _updatingBookingId = bookingId;
    });
    try {
      final currentUser = getIt<GetCurrentUserUseCase>()();
      final userId = currentUser?.uid ?? 'admin';
      await getIt<UpdateBookingRefundStatusUseCase>()(
        bookingId: bookingId,
        status: status,
        actorUserId: userId,
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingBookingId = null;
        });
      }
    }
  }

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
          return AdminWebPanel(
            child: _PanelMessage(
              message: 'Failed to load refunds: ${snapshot.error}',
              isError: true,
            ),
          );
        }

        final cancelledBookings = List<BookingEntity>.from(
          (snapshot.data ?? const <BookingEntity>[]).where((item) {
            final status = item.status.trim().toLowerCase();
            return status == 'cancelled' || status == 'canceled';
          }),
        )..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final venueOptions =
            cancelledBookings
                .map(_venueName)
                .where((name) => name != '-')
                .toSet()
                .toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        final filteredItems = _applyFilters(cancelledBookings);
        final pendingCount = cancelledBookings
            .where((item) => _refundStatus(item) == 'pending')
            .length;
        final checkedCount = cancelledBookings
            .where((item) => _refundStatus(item) == 'checked')
            .length;
        final refundedCount = cancelledBookings
            .where((item) => _refundStatus(item) == 'refunded')
            .length;

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final spacing = 16.w;
                final columns = constraints.maxWidth >= 1000
                    ? 4
                    : constraints.maxWidth >= 680
                    ? 2
                    : 1;
                final cardWidth = columns == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - (spacing * (columns - 1))) /
                          columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: 16.h,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: AdminWebMetricCard(
                        title: 'Cancelled bookings',
                        value: '${cancelledBookings.length}',
                        icon: Icons.cancel_schedule_send_outlined,
                        iconColor: AppColors.primary,
                        caption: 'All bookings waiting for refund review',
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminWebMetricCard(
                        title: 'Pending review',
                        value: '$pendingCount',
                        icon: Icons.hourglass_bottom_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        caption: 'No refund action taken yet',
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminWebMetricCard(
                        title: 'Checked',
                        value: '$checkedCount',
                        icon: Icons.rule_folder_outlined,
                        iconColor: const Color(0xFF2563EB),
                        caption: 'Validated and awaiting transfer',
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminWebMetricCard(
                        title: 'Refunded',
                        value: '$refundedCount',
                        icon: Icons.check_circle_outline,
                        iconColor: const Color(0xFF0E9F6E),
                        caption: 'Marked as refunded in the system',
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 20.h),
            AdminWebPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RefundsToolbar(
                    searchController: _searchController,
                    venueFilter: venueOptions.contains(_venueFilter)
                        ? _venueFilter
                        : 'all',
                    venueOptions: venueOptions,
                    sortBy: _sortBy,
                    onVenueChanged: (value) =>
                        setState(() => _venueFilter = value),
                    onSortChanged: (value) => setState(() => _sortBy = value),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _refundFilter == 'all',
                        onTap: () => setState(() => _refundFilter = 'all'),
                      ),
                      _FilterChip(
                        label: 'Pending',
                        selected: _refundFilter == 'pending',
                        onTap: () => setState(() => _refundFilter = 'pending'),
                      ),
                      _FilterChip(
                        label: 'Checked',
                        selected: _refundFilter == 'checked',
                        onTap: () => setState(() => _refundFilter = 'checked'),
                      ),
                      _FilterChip(
                        label: 'Refunded',
                        selected: _refundFilter == 'refunded',
                        onTap: () => setState(() => _refundFilter = 'refunded'),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  if (filteredItems.isEmpty)
                    const _PanelMessage(
                      message:
                          'No cancelled bookings match the current filters.',
                    )
                  else
                    Column(
                      children: [
                        for (
                          var index = 0;
                          index < filteredItems.length;
                          index++
                        ) ...[
                          _RefundCard(
                            booking: filteredItems[index],
                            customerInfo:
                                _customerCache[filteredItems[index].userId],
                            isUpdating:
                                _updatingBookingId == filteredItems[index].id,
                            onUpdateRefundStatus: _updateRefundStatus,
                          ),
                          if (index != filteredItems.length - 1)
                            SizedBox(height: 14.h),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

enum _RefundsSort {
  cancelledNewest,
  cancelledOldest,
  venueAsc,
  venueDesc,
  amountHigh,
  amountLow,
}

class _RefundsToolbar extends StatelessWidget {
  const _RefundsToolbar({
    required this.searchController,
    required this.venueFilter,
    required this.venueOptions,
    required this.sortBy,
    required this.onVenueChanged,
    required this.onSortChanged,
  });

  final TextEditingController searchController;
  final String venueFilter;
  final List<String> venueOptions;
  final _RefundsSort sortBy;
  final ValueChanged<String> onVenueChanged;
  final ValueChanged<_RefundsSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final venueField = AdminWebFilterDropdownField<String>(
          label: 'Venue',
          value: venueFilter,
          items: [
            const DropdownMenuItem(value: 'all', child: Text('All venues')),
            ...venueOptions.map(
              (name) => DropdownMenuItem(value: name, child: Text(name)),
            ),
          ],
          onChanged: onVenueChanged,
        );
        final sortField = AdminWebFilterDropdownField<_RefundsSort>(
          label: 'Sort by',
          value: sortBy,
          items: const [
            DropdownMenuItem(
              value: _RefundsSort.cancelledNewest,
              child: Text('Newest cancelled'),
            ),
            DropdownMenuItem(
              value: _RefundsSort.cancelledOldest,
              child: Text('Oldest cancelled'),
            ),
            DropdownMenuItem(
              value: _RefundsSort.venueAsc,
              child: Text('Venue A-Z'),
            ),
            DropdownMenuItem(
              value: _RefundsSort.venueDesc,
              child: Text('Venue Z-A'),
            ),
            DropdownMenuItem(
              value: _RefundsSort.amountHigh,
              child: Text('Amount high-low'),
            ),
            DropdownMenuItem(
              value: _RefundsSort.amountLow,
              child: Text('Amount low-high'),
            ),
          ],
          onChanged: onSortChanged,
        );

        if (constraints.maxWidth < 1180) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SearchField(
                controller: searchController,
                hintText:
                    'Search by booking code, venue, offer, customer, phone, or schedule',
              ),
              SizedBox(height: 12.h),
              venueField,
              SizedBox(height: 12.h),
              sortField,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _SearchField(
                controller: searchController,
                hintText:
                    'Search by booking code, venue, offer, customer, phone, or schedule',
              ),
            ),
            SizedBox(width: 12.w),
            SizedBox(width: 220.w, child: venueField),
            SizedBox(width: 12.w),
            SizedBox(width: 220.w, child: sortField),
          ],
        );
      },
    );
  }
}

class _RefundCard extends StatelessWidget {
  const _RefundCard({
    required this.booking,
    required this.customerInfo,
    required this.isUpdating,
    required this.onUpdateRefundStatus,
  });

  final BookingEntity booking;
  final _RefundCustomerInfo? customerInfo;
  final bool isUpdating;
  final Future<void> Function(String bookingId, String status)
  onUpdateRefundStatus;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d, yyyy - HH:mm');
    final refundStatus = _refundStatus(booking);
    final canMarkChecked =
        !isUpdating && refundStatus != 'checked' && refundStatus != 'refunded';
    final canMarkRefunded = !isUpdating && refundStatus != 'refunded';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFF),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE8EDF4)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 860;
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (booking.restaurantNameSnapshot ?? '').trim().isEmpty
                    ? booking.restaurantId
                    : booking.restaurantNameSnapshot!,
                style: AppTextStyles.sectionTitle,
              ),
              SizedBox(height: 6.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 8.h,
                children: [
                  Text(
                    'Code: ${booking.bookingCode}',
                    style: AppTextStyles.cardMeta,
                  ),
                  Text(
                    'Schedule: ${booking.date} ${booking.startTime}',
                    style: AppTextStyles.cardMeta,
                  ),
                  Text(
                    'Amount: ${booking.currency} ${booking.total.toStringAsFixed(2)}',
                    style: AppTextStyles.cardMeta.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                (booking.offerTitleSnapshot ?? '').trim().isEmpty
                    ? booking.offerId
                    : booking.offerTitleSnapshot!,
                style: AppTextStyles.cardMeta.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Cancelled at: ${formatter.format(booking.createdAt)}',
                style: AppTextStyles.cardMeta,
              ),
              SizedBox(height: 4.h),
              Text(
                'Customer: ${customerInfo?.displayName(booking.userId) ?? _fallbackCustomerName(booking.userId)}',
                style: AppTextStyles.cardMeta,
              ),
              SizedBox(height: 4.h),
              Text(
                'Phone: ${customerInfo?.displayPhone ?? '-'}',
                style: AppTextStyles.cardMeta.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          );

          final actions = Column(
            crossAxisAlignment: stacked
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              _StatusPill(
                label: _titleCase(refundStatus),
                color: _refundColor(refundStatus),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  OutlinedButton(
                    onPressed: canMarkChecked
                        ? () => onUpdateRefundStatus(booking.id, 'checked')
                        : null,
                    child: isUpdating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Mark checked'),
                  ),
                  ElevatedButton(
                    onPressed: canMarkRefunded
                        ? () => onUpdateRefundStatus(booking.id, 'refunded')
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Mark refunded'),
                  ),
                ],
              ),
            ],
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                details,
                SizedBox(height: 16.h),
                actions,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: details),
              SizedBox(width: 20.w),
              actions,
            ],
          );
        },
      ),
    );
  }
}

String _fallbackCustomerName(String userId) {
  final normalized = userId.trim();
  return normalized.isEmpty ? '-' : normalized;
}

class _RefundCustomerInfo {
  const _RefundCustomerInfo({required this.fullName, required this.phone});

  final String fullName;
  final String phone;

  String displayName(String fallbackUserId) {
    if (fullName.trim().isNotEmpty) return fullName.trim();
    return _fallbackCustomerName(fallbackUserId);
  }

  String get displayPhone {
    final normalized = phone.trim();
    return normalized.isEmpty ? '-' : normalized;
  }
}

String _refundStatus(BookingEntity booking) {
  final value = (booking.refundStatus ?? '').trim().toLowerCase();
  if (value == 'checked' || value == 'refunded') return value;
  return 'pending';
}

Color _refundColor(String state) {
  switch (state) {
    case 'checked':
      return const Color(0xFF2563EB);
    case 'refunded':
      return const Color(0xFF0E9F6E);
    default:
      return const Color(0xFFF59E0B);
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.hintText});

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.22),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withValues(alpha: 0.16),
      labelStyle: AppTextStyles.cardMeta.copyWith(
        color: selected ? AppColors.primaryDark : AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.18)
            : const Color(0xFFE5EAF1),
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999.r)),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.cardMeta.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PanelMessage extends StatelessWidget {
  const _PanelMessage({required this.message, this.isError = false});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18.h),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.cardMeta.copyWith(
            color: isError ? const Color(0xFFC62828) : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
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
