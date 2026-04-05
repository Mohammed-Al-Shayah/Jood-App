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
    final normalized = trimmed.replaceAll('.', '');
    final hasAmPm = normalized.endsWith('am') || normalized.endsWith('pm');
    if (hasAmPm) {
      final period = normalized.substring(normalized.length - 2);
      final timePart = normalized.substring(0, normalized.length - 2).trim();
      final segments = timePart.split(':');
      final hour = int.tryParse(segments.first);
      final minute = segments.length > 1
          ? int.tryParse(segments[1].trim()) ?? 0
          : 0;
      if (hour == null) return null;
      var normalizedHour = hour % 12;
      if (period == 'pm') normalizedHour += 12;
      return normalizedHour * 60 + minute;
    }
    final segments24 = trimmed.split(':');
    if (segments24.length == 2) {
      final hour = int.tryParse(segments24[0].trim());
      final minute = int.tryParse(segments24[1].trim());
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
