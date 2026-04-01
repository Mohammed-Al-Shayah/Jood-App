import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/features/admin/presentation/web/admin_web_navigation.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_metric_card.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_panel.dart';
import 'package:jood/features/bookings/data/models/booking_model.dart';
import 'package:jood/features/bookings/domain/entities/booking_entity.dart';

class AdminWebBookingsPage extends StatefulWidget {
  const AdminWebBookingsPage({super.key, this.initialRequest});

  final AdminWebSectionRequest? initialRequest;

  @override
  State<AdminWebBookingsPage> createState() => _AdminWebBookingsPageState();
}

class _AdminWebBookingsPageState extends State<AdminWebBookingsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'all';
  String _typeFilter = 'all';
  String _venueFilter = 'all';
  AdminWebTimeFilter _timeFilter = AdminWebTimeFilter.allTime;
  _BookingsSort _sortBy = _BookingsSort.createdNewest;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _applyInitialRequest(widget.initialRequest);
  }

  @override
  void didUpdateWidget(covariant AdminWebBookingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRequest?.cacheKey == widget.initialRequest?.cacheKey) {
      return;
    }
    _applyInitialRequest(widget.initialRequest);
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

  void _applyInitialRequest(AdminWebSectionRequest? request) {
    if (request == null) return;
    _timeFilter = request.timeFilter;
    _statusFilter = _normalizedStatusFilter(request.bookingStatus);
  }

  String _normalizedStatusFilter(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    if (normalized.isEmpty) return 'all';
    return normalized;
  }

  List<BookingEntity> _applyTimeFilter(List<BookingEntity> items) {
    final now = DateTime.now();
    return items
        .where((booking) => _timeFilter.includes(booking.createdAt, now: now))
        .toList(growable: false);
  }

  List<BookingEntity> _applyFilters(List<BookingEntity> items) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = items
        .where((booking) {
          final status = booking.status.trim().toLowerCase();
          final type = _normalizedType(booking);
          final venueName = _venueName(booking).toLowerCase();
          if (_statusFilter != 'all' && status != _statusFilter) {
            return false;
          }
          if (_typeFilter != 'all' && type != _typeFilter) {
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
            booking.userId,
            booking.date,
            booking.startTime,
            booking.status,
            booking.bookableType ?? '',
          ].join(' ').toLowerCase();
          return haystack.contains(query);
        })
        .toList(growable: false);

    filtered.sort((a, b) {
      switch (_sortBy) {
        case _BookingsSort.createdNewest:
          return b.createdAt.compareTo(a.createdAt);
        case _BookingsSort.createdOldest:
          return a.createdAt.compareTo(b.createdAt);
        case _BookingsSort.venueAsc:
          return _venueName(
            a,
          ).toLowerCase().compareTo(_venueName(b).toLowerCase());
        case _BookingsSort.venueDesc:
          return _venueName(
            b,
          ).toLowerCase().compareTo(_venueName(a).toLowerCase());
        case _BookingsSort.totalHigh:
          return b.total.compareTo(a.total);
        case _BookingsSort.totalLow:
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

  String _normalizedType(BookingEntity booking) {
    final raw = (booking.bookableType ?? '').trim().toLowerCase();
    return raw.isEmpty ? 'restaurant' : raw;
  }

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('bookings')
        .orderBy('createdAt', descending: true)
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
              message: 'Failed to load bookings: ${snapshot.error}',
              isError: true,
            ),
          );
        }

        final bookings = (snapshot.data?.docs ?? const [])
            .map(BookingModel.fromDoc)
            .toList(growable: false);
        final timeFilteredItems = _applyTimeFilter(bookings);
        final venueOptions =
            timeFilteredItems
                .map(_venueName)
                .map((name) => name.trim())
                .where((name) => name.isNotEmpty && name != '-')
                .toSet()
                .toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        final filteredItems = _applyFilters(timeFilteredItems);
        final paidCount = timeFilteredItems.where((booking) {
          final status = booking.status.trim().toLowerCase();
          return status == 'paid' || status == 'confirmed';
        }).length;
        final cancelledCount = timeFilteredItems
            .where(
              (booking) => booking.status.trim().toLowerCase() == 'cancelled',
            )
            .length;
        final revenue = timeFilteredItems.fold<double>(0, (
          accumulated,
          booking,
        ) {
          final status = booking.status.trim().toLowerCase();
          if (status == 'cancelled' || status == 'failed') {
            return accumulated;
          }
          return accumulated + booking.total;
        });

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final spacing = 16.w;
                final columns = constraints.maxWidth >= 1000
                    ? 3
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
                        title: 'All bookings',
                        value: '${timeFilteredItems.length}',
                        icon: Icons.receipt_long_outlined,
                        iconColor: AppColors.primary,
                        caption: _timeFilter == AdminWebTimeFilter.allTime
                            ? 'Every booking document in Firestore'
                            : 'Filtered to ${_timeFilter.label.toLowerCase()}',
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminWebMetricCard(
                        title: 'Paid or confirmed',
                        value: '$paidCount',
                        icon: Icons.check_circle_outline,
                        iconColor: const Color(0xFF0E9F6E),
                        caption:
                            '$cancelledCount cancelled in ${_timeFilter.describeWindow()}',
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: AdminWebMetricCard(
                        title: 'Gross revenue',
                        value: 'OMR ${revenue.toStringAsFixed(2)}',
                        icon: Icons.payments_outlined,
                        iconColor: const Color(0xFF2563EB),
                        caption: 'Excludes cancelled and failed bookings',
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
                  _BookingsToolbar(
                    searchController: _searchController,
                    venueFilter: _venueFilter,
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
                      for (final option in AdminWebTimeFilter.values)
                        _FilterChip(
                          label: option.shortLabel,
                          selected: _timeFilter == option,
                          onTap: () => setState(() => _timeFilter = option),
                        ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _FilterChip(
                        label: 'All status',
                        selected: _statusFilter == 'all',
                        onTap: () => setState(() => _statusFilter = 'all'),
                      ),
                      _FilterChip(
                        label: 'Pending',
                        selected: _statusFilter == 'pending',
                        onTap: () => setState(() => _statusFilter = 'pending'),
                      ),
                      _FilterChip(
                        label: 'Paid',
                        selected: _statusFilter == 'paid',
                        onTap: () => setState(() => _statusFilter = 'paid'),
                      ),
                      _FilterChip(
                        label: 'Confirmed',
                        selected: _statusFilter == 'confirmed',
                        onTap: () =>
                            setState(() => _statusFilter = 'confirmed'),
                      ),
                      _FilterChip(
                        label: 'Cancelled',
                        selected: _statusFilter == 'cancelled',
                        onTap: () =>
                            setState(() => _statusFilter = 'cancelled'),
                      ),
                      _FilterChip(
                        label: 'All types',
                        selected: _typeFilter == 'all',
                        onTap: () => setState(() => _typeFilter = 'all'),
                      ),
                      _FilterChip(
                        label: 'Restaurant',
                        selected: _typeFilter == 'restaurant',
                        onTap: () => setState(() => _typeFilter = 'restaurant'),
                      ),
                      _FilterChip(
                        label: 'Attraction',
                        selected: _typeFilter == 'attraction',
                        onTap: () => setState(() => _typeFilter = 'attraction'),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  if (filteredItems.isEmpty)
                    const _PanelMessage(
                      message: 'No bookings match the current filters.',
                    )
                  else
                    _BookingsTable(items: filteredItems),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

enum _BookingsSort {
  createdNewest,
  createdOldest,
  venueAsc,
  venueDesc,
  totalHigh,
  totalLow,
}

class _BookingsTable extends StatelessWidget {
  const _BookingsTable({required this.items});

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
        dataRowMaxHeight: 82.h,
        columns: const [
          DataColumn(label: Text('Code')),
          DataColumn(label: Text('Venue')),
          DataColumn(label: Text('Offer')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Guests')),
          DataColumn(label: Text('Schedule')),
          DataColumn(label: Text('Total')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Created')),
        ],
        rows: items
            .map((booking) {
              final created = formatter.format(booking.createdAt);
              final type = (booking.bookableType ?? '').trim().isEmpty
                  ? 'restaurant'
                  : booking.bookableType!;
              return DataRow(
                cells: [
                  DataCell(Text(booking.bookingCode)),
                  DataCell(
                    SizedBox(
                      width: 200.w,
                      child: Text(
                        (booking.restaurantNameSnapshot ?? '').trim().isNotEmpty
                            ? booking.restaurantNameSnapshot!
                            : booking.restaurantId,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 220.w,
                      child: Text(
                        (booking.offerTitleSnapshot ?? '').trim().isNotEmpty
                            ? booking.offerTitleSnapshot!
                            : booking.offerId,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text(_titleCase(type))),
                  DataCell(Text('${booking.adults + booking.children}')),
                  DataCell(Text('${booking.date}  ${booking.startTime}')),
                  DataCell(
                    Text(
                      '${booking.currency} ${booking.total.toStringAsFixed(2)}',
                    ),
                  ),
                  DataCell(
                    _StatusPill(
                      label: _titleCase(booking.status),
                      color: _statusColor(booking.status),
                    ),
                  ),
                  DataCell(Text(created)),
                ],
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _BookingsToolbar extends StatelessWidget {
  const _BookingsToolbar({
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
  final _BookingsSort sortBy;
  final ValueChanged<String> onVenueChanged;
  final ValueChanged<_BookingsSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final selectedVenue =
            venueFilter == 'all' || venueOptions.contains(venueFilter)
            ? venueFilter
            : 'all';
        final venueField = _DropdownFilterField<String>(
          label: 'Venue',
          value: selectedVenue,
          items: [
            const DropdownMenuItem(value: 'all', child: Text('All venues')),
            ...venueOptions.map(
              (name) => DropdownMenuItem(value: name, child: Text(name)),
            ),
          ],
          onChanged: onVenueChanged,
        );
        final sortField = _DropdownFilterField<_BookingsSort>(
          label: 'Sort by',
          value: sortBy,
          items: const [
            DropdownMenuItem(
              value: _BookingsSort.createdNewest,
              child: Text('Newest first'),
            ),
            DropdownMenuItem(
              value: _BookingsSort.createdOldest,
              child: Text('Oldest first'),
            ),
            DropdownMenuItem(
              value: _BookingsSort.venueAsc,
              child: Text('Venue A-Z'),
            ),
            DropdownMenuItem(
              value: _BookingsSort.venueDesc,
              child: Text('Venue Z-A'),
            ),
            DropdownMenuItem(
              value: _BookingsSort.totalHigh,
              child: Text('Amount high-low'),
            ),
            DropdownMenuItem(
              value: _BookingsSort.totalLow,
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
                    'Search by code, venue, offer, user id, date, or type',
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
                    'Search by code, venue, offer, user id, date, or type',
              ),
            ),
            SizedBox(width: 12.w),
            SizedBox(width: 240.w, child: venueField),
            SizedBox(width: 12.w),
            SizedBox(width: 220.w, child: sortField),
          ],
        );
      },
    );
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

class _DropdownFilterField<T> extends StatelessWidget {
  const _DropdownFilterField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
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
      items: items,
      onChanged: (value) {
        if (value == null) return;
        onChanged(value);
      },
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

Color _statusColor(String status) {
  switch (status.trim().toLowerCase()) {
    case 'paid':
    case 'confirmed':
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
