import 'package:flutter/material.dart';

enum AdminWebSection {
  overview(
    label: 'Overview',
    subtitle: 'KPIs, revenue, live metrics, and recent activity',
    icon: Icons.grid_view_rounded,
  ),
  restaurants(
    label: 'Restaurants',
    subtitle: 'Listings, venue health, and status management',
    icon: Icons.storefront_outlined,
  ),
  buffet(
    label: 'Buffet',
    subtitle: 'Meal-based buffet inventory and participating venues',
    icon: Icons.restaurant_menu_outlined,
  ),
  setMenu(
    label: 'Set Menu',
    subtitle: 'Curated set menu inventory across restaurant partners',
    icon: Icons.menu_book_outlined,
  ),
  combo(
    label: 'Combo',
    subtitle:
        'Fixed-price combo inventory and quantity-based restaurant offers',
    icon: Icons.fastfood_rounded,
  ),
  attractions(
    label: 'Attractions',
    subtitle: 'Time-slot and package inventory for attraction experiences',
    icon: Icons.local_activity_outlined,
  ),
  offers(
    label: 'Offers',
    subtitle: 'Availability, pricing, and inventory control',
    icon: Icons.local_offer_outlined,
  ),
  bookings(
    label: 'Bookings',
    subtitle: 'Recent orders, statuses, and operational tracking',
    icon: Icons.receipt_long_outlined,
  ),
  payments(
    label: 'Payments',
    subtitle: 'Transactions, payment states, and collected totals',
    icon: Icons.credit_card_outlined,
  ),
  refunds(
    label: 'Refunds',
    subtitle: 'Cancelled bookings, refund review, and reconciliation',
    icon: Icons.replay_circle_filled_outlined,
  ),
  users(
    label: 'Users',
    subtitle: 'Access, roles, and customer directory',
    icon: Icons.people_outline,
  );

  const AdminWebSection({
    required this.label,
    required this.subtitle,
    required this.icon,
  });

  final String label;
  final String subtitle;
  final IconData icon;
}

enum AdminWebTimeFilter {
  last7Days(label: 'Last 7 days', shortLabel: '7D', days: 7),
  last30Days(label: 'Last 30 days', shortLabel: '30D', days: 30),
  last90Days(label: 'Last 90 days', shortLabel: '90D', days: 90),
  allTime(label: 'All time', shortLabel: 'All', days: null);

  const AdminWebTimeFilter({
    required this.label,
    required this.shortLabel,
    required this.days,
  });

  final String label;
  final String shortLabel;
  final int? days;

  DateTime? startDate({DateTime? now}) {
    if (days == null) return null;
    final reference = DateUtils.dateOnly(now ?? DateTime.now());
    return reference.subtract(Duration(days: days! - 1));
  }

  bool includes(DateTime value, {DateTime? now}) {
    final start = startDate(now: now);
    if (start == null) return true;
    return !value.isBefore(start);
  }

  String describeWindow() {
    return days == null ? 'all recorded time' : label.toLowerCase();
  }
}

@immutable
class AdminWebSectionRequest {
  const AdminWebSectionRequest({
    this.timeFilter = AdminWebTimeFilter.allTime,
    this.bookingStatus,
    this.paymentState,
  });

  final AdminWebTimeFilter timeFilter;
  final String? bookingStatus;
  final String? paymentState;

  String get cacheKey {
    return '${timeFilter.name}|${bookingStatus ?? '-'}|${paymentState ?? '-'}';
  }
}

typedef AdminWebSectionSelector =
    void Function(AdminWebSection section, {AdminWebSectionRequest? request});
