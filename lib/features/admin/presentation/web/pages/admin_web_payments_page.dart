import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_filter_dropdown_field.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_metric_card.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_panel.dart';
import 'package:jood/features/bookings/data/models/booking_model.dart';
import 'package:jood/features/bookings/domain/entities/booking_entity.dart';

class AdminWebPaymentsPage extends StatefulWidget {
  const AdminWebPaymentsPage({super.key});

  @override
  State<AdminWebPaymentsPage> createState() => _AdminWebPaymentsPageState();
}

class _AdminWebPaymentsPageState extends State<AdminWebPaymentsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _paymentFilter = 'all';
  String _venueFilter = 'all';
  _PaymentsSort _sortBy = _PaymentsSort.createdNewest;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
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

  List<BookingEntity> _applyFilters(List<BookingEntity> items) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = items
        .where((booking) {
          final paymentState = _paymentState(booking);
          final venueName = _venueName(booking).toLowerCase();
          if (_paymentFilter != 'all' && paymentState != _paymentFilter) {
            return false;
          }
          if (_venueFilter != 'all' &&
              venueName != _venueFilter.toLowerCase()) {
            return false;
          }
          if (query.isEmpty) return true;
          final haystack = [
            booking.bookingCode,
            _venueName(booking),
            booking.offerTitleSnapshot ?? '',
            booking.paymentSessionId ?? '',
            booking.userId,
            booking.status,
            booking.date,
            booking.startTime,
          ].join(' ').toLowerCase();
          return haystack.contains(query);
        })
        .toList(growable: false);

    filtered.sort((a, b) {
      switch (_sortBy) {
        case _PaymentsSort.createdNewest:
          return b.createdAt.compareTo(a.createdAt);
        case _PaymentsSort.createdOldest:
          return a.createdAt.compareTo(b.createdAt);
        case _PaymentsSort.venueAsc:
          return _venueName(
            a,
          ).toLowerCase().compareTo(_venueName(b).toLowerCase());
        case _PaymentsSort.venueDesc:
          return _venueName(
            b,
          ).toLowerCase().compareTo(_venueName(a).toLowerCase());
        case _PaymentsSort.amountHigh:
          return b.total.compareTo(a.total);
        case _PaymentsSort.amountLow:
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

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('bookings')
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return AdminWebPanel(
            child: _PanelMessage(
              message: 'Failed to load payments: ${snapshot.error}',
              isError: true,
            ),
          );
        }

        final bookings =
            (snapshot.data?.docs ?? const [])
                .map(BookingModel.fromDoc)
                .toList(growable: false)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final venueOptions =
            bookings
                .map(_venueName)
                .where((name) => name != '-')
                .toSet()
                .toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        final filteredItems = _applyFilters(bookings);
        final paidItems = bookings.where(
          (item) => _paymentState(item) == 'paid',
        );
        final pendingItems = bookings.where(
          (item) => _paymentState(item) == 'pending',
        );
        final paidRevenue = paidItems.fold<double>(
          0,
          (totalAmount, item) => totalAmount + item.total,
        );
        final pendingRevenue = pendingItems.fold<double>(
          0,
          (totalAmount, item) => totalAmount + item.total,
        );
        final failedOrCancelledCount = bookings.where((item) {
          final state = _paymentState(item);
          return state == 'cancelled' || state == 'failed';
        }).length;

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
                        title: 'Payment records',
                        value: '${bookings.length}',
                        icon: Icons.credit_card_outlined,
                        iconColor: AppColors.primary,
                        caption: 'All bookings with payment metadata',
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminWebMetricCard(
                        title: 'Paid',
                        value: '${paidItems.length}',
                        icon: Icons.check_circle_outline,
                        iconColor: const Color(0xFF0E9F6E),
                        caption: _formatMoney(paidRevenue),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminWebMetricCard(
                        title: 'Pending',
                        value: '${pendingItems.length}',
                        icon: Icons.hourglass_top_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        caption: _formatMoney(pendingRevenue),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminWebMetricCard(
                        title: 'Cancelled / failed',
                        value: '$failedOrCancelledCount',
                        icon: Icons.cancel_outlined,
                        iconColor: const Color(0xFFD14343),
                        caption: 'Payments not completed successfully',
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
                  _PaymentsToolbar(
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
                        selected: _paymentFilter == 'all',
                        onTap: () => setState(() => _paymentFilter = 'all'),
                      ),
                      _FilterChip(
                        label: 'Paid',
                        selected: _paymentFilter == 'paid',
                        onTap: () => setState(() => _paymentFilter = 'paid'),
                      ),
                      _FilterChip(
                        label: 'Pending',
                        selected: _paymentFilter == 'pending',
                        onTap: () => setState(() => _paymentFilter = 'pending'),
                      ),
                      _FilterChip(
                        label: 'Unpaid',
                        selected: _paymentFilter == 'unpaid',
                        onTap: () => setState(() => _paymentFilter = 'unpaid'),
                      ),
                      _FilterChip(
                        label: 'Cancelled',
                        selected: _paymentFilter == 'cancelled',
                        onTap: () =>
                            setState(() => _paymentFilter = 'cancelled'),
                      ),
                      _FilterChip(
                        label: 'Failed',
                        selected: _paymentFilter == 'failed',
                        onTap: () => setState(() => _paymentFilter = 'failed'),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  if (filteredItems.isEmpty)
                    const _PanelMessage(
                      message: 'No payments match the current filters.',
                    )
                  else
                    _PaymentsTable(items: filteredItems),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

enum _PaymentsSort {
  createdNewest,
  createdOldest,
  venueAsc,
  venueDesc,
  amountHigh,
  amountLow,
}

class _PaymentsToolbar extends StatelessWidget {
  const _PaymentsToolbar({
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
  final _PaymentsSort sortBy;
  final ValueChanged<String> onVenueChanged;
  final ValueChanged<_PaymentsSort> onSortChanged;

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
        final sortField = AdminWebFilterDropdownField<_PaymentsSort>(
          label: 'Sort by',
          value: sortBy,
          items: const [
            DropdownMenuItem(
              value: _PaymentsSort.createdNewest,
              child: Text('Newest first'),
            ),
            DropdownMenuItem(
              value: _PaymentsSort.createdOldest,
              child: Text('Oldest first'),
            ),
            DropdownMenuItem(
              value: _PaymentsSort.venueAsc,
              child: Text('Venue A-Z'),
            ),
            DropdownMenuItem(
              value: _PaymentsSort.venueDesc,
              child: Text('Venue Z-A'),
            ),
            DropdownMenuItem(
              value: _PaymentsSort.amountHigh,
              child: Text('Amount high-low'),
            ),
            DropdownMenuItem(
              value: _PaymentsSort.amountLow,
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
                    'Search by booking code, venue, offer, session, or user',
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
                    'Search by booking code, venue, offer, session, or user',
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

class _PaymentsTable extends StatelessWidget {
  const _PaymentsTable({required this.items});

  final List<BookingEntity> items;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d, yyyy - HH:mm');
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 22.w,
        headingRowHeight: 48.h,
        dataRowMinHeight: 70.h,
        dataRowMaxHeight: 84.h,
        columns: const [
          DataColumn(label: Text('Code')),
          DataColumn(label: Text('Venue')),
          DataColumn(label: Text('Offer')),
          DataColumn(label: Text('Payment state')),
          DataColumn(label: Text('Session')),
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('Paid at')),
          DataColumn(label: Text('Created')),
        ],
        rows: items
            .map((booking) {
              return DataRow(
                cells: [
                  DataCell(Text(booking.bookingCode)),
                  DataCell(
                    SizedBox(
                      width: 180.w,
                      child: Text(
                        (booking.restaurantNameSnapshot ?? '').trim().isEmpty
                            ? booking.restaurantId
                            : booking.restaurantNameSnapshot!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 220.w,
                      child: Text(
                        (booking.offerTitleSnapshot ?? '').trim().isEmpty
                            ? booking.offerId
                            : booking.offerTitleSnapshot!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    _StatusPill(
                      label: _titleCase(_paymentState(booking)),
                      color: _paymentColor(_paymentState(booking)),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 180.w,
                      child: Text(
                        (booking.paymentSessionId ?? '').trim().isEmpty
                            ? '-'
                            : booking.paymentSessionId!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${booking.currency} ${booking.total.toStringAsFixed(2)}',
                    ),
                  ),
                  DataCell(
                    Text(
                      booking.paidAt == null
                          ? '-'
                          : formatter.format(booking.paidAt!),
                    ),
                  ),
                  DataCell(Text(formatter.format(booking.createdAt))),
                ],
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

String _paymentState(BookingEntity booking) {
  final status = booking.status.trim().toLowerCase();
  if (status == 'cancelled' || status == 'canceled') return 'cancelled';
  if (status == 'failed') return 'failed';
  if (status == 'paid' || status == 'confirmed' || booking.paidAt != null) {
    return 'paid';
  }
  if ((booking.paymentSessionId ?? '').trim().isNotEmpty) return 'pending';
  return 'unpaid';
}

Color _paymentColor(String state) {
  switch (state) {
    case 'paid':
      return const Color(0xFF0E9F6E);
    case 'pending':
      return const Color(0xFFF59E0B);
    case 'cancelled':
    case 'failed':
      return const Color(0xFFD14343);
    default:
      return const Color(0xFF2563EB);
  }
}

String _formatMoney(double amount) => 'OMR ${amount.toStringAsFixed(2)}';

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
