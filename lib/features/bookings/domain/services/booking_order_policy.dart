class BookingOrderPolicy {
  static bool isCancelledStatus(String statusValue) {
    final normalized = statusValue.trim().toLowerCase();
    return normalized == 'cancelled' || normalized == 'canceled';
  }

  static bool isCompletedStatus(String statusValue) {
    final normalized = statusValue.trim().toLowerCase();
    return normalized == 'completed' || normalized == 'complete';
  }

  static bool canShowQr(String statusValue) {
    final normalized = statusValue.trim().toLowerCase();
    return normalized == 'paid' || normalized == 'confirmed';
  }

  static bool isCancellationAllowed({
    required String date,
    required String startTime,
    required String endTime,
    DateTime? now,
  }) {
    final endMinutes = _parseTimeToMinutes(endTime);
    final startMinutes = _parseTimeToMinutes(startTime);
    if (endMinutes == null && startMinutes == null) return false;
    var endDate = _buildDateTimeFromMinutes(date, endMinutes ?? startMinutes);
    if (endDate == null) return false;
    if (endMinutes != null &&
        startMinutes != null &&
        endMinutes <= startMinutes) {
      endDate = endDate.add(const Duration(days: 1));
    }
    return (now ?? DateTime.now()).isBefore(endDate);
  }

  static DateTime? _parseBookingDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final parsed = DateTime.tryParse(trimmed);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static int? _parseTimeToMinutes(String value) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) return null;
    final amPmMatch = RegExp(
      r'^(\d{1,2})(?::(\d{2}))?\s*([ap]m)$',
    ).firstMatch(trimmed);
    if (amPmMatch != null) {
      final hour = int.tryParse(amPmMatch.group(1) ?? '');
      final minute = int.tryParse(amPmMatch.group(2) ?? '0') ?? 0;
      final period = amPmMatch.group(3);
      if (hour == null) return null;
      var normalizedHour = hour % 12;
      if (period == 'pm') normalizedHour += 12;
      return normalizedHour * 60 + minute;
    }
    final match24 = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(trimmed);
    if (match24 != null) {
      final hour = int.tryParse(match24.group(1) ?? '');
      final minute = int.tryParse(match24.group(2) ?? '');
      if (hour == null || minute == null) return null;
      return hour * 60 + minute;
    }
    return null;
  }

  static DateTime? _buildDateTimeFromMinutes(String date, int? minutes) {
    if (minutes == null) return null;
    final baseDate = _parseBookingDate(date);
    if (baseDate == null) return null;
    return baseDate.add(Duration(minutes: minutes));
  }
}
