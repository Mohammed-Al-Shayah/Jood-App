import 'package:equatable/equatable.dart';

class AdEntity extends Equatable {
  const AdEntity({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.isActive,
    required this.sortOrder,
    required this.displaySeconds,
    required this.targetCategory,
    required this.targetVenueId,
    required this.targetVenueName,
    required this.targetOfferId,
    required this.targetOfferTitle,
    required this.targetOfferDate,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String imageUrl;
  final bool isActive;
  final int sortOrder;
  final int displaySeconds;
  final String targetCategory;
  final String targetVenueId;
  final String targetVenueName;
  final String targetOfferId;
  final String targetOfferTitle;
  final String targetOfferDate;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get resolvedDisplaySeconds => displaySeconds.clamp(1, 10);

  bool get hasValidHomeSliderTarget =>
      targetOfferId.trim().isNotEmpty &&
      targetVenueId.trim().isNotEmpty &&
      targetCategory.trim().isNotEmpty &&
      imageUrl.trim().isNotEmpty;

  DateTime? get scheduleStartAt => _parseDateTime(
    startDate,
    startTime,
    endOfDayWhenTimeMissing: false,
  );

  DateTime? get scheduleEndAt =>
      _parseDateTime(endDate, endTime, endOfDayWhenTimeMissing: true) ??
      _parseDateTime(
        targetOfferDate,
        '',
        endOfDayWhenTimeMissing: true,
      );

  bool canShowOnHomeSliderAt([DateTime? moment]) {
    if (!isActive || !hasValidHomeSliderTarget) return false;

    final now = moment ?? DateTime.now();
    final start = scheduleStartAt;
    final end = scheduleEndAt;

    if (start != null && now.isBefore(start)) {
      return false;
    }
    if (end != null && now.isAfter(end)) {
      return false;
    }

    return true;
  }

  static DateTime? _parseDateTime(
    String dateValue,
    String timeValue, {
    required bool endOfDayWhenTimeMissing,
  }) {
    final parsedDate = DateTime.tryParse(dateValue.trim());
    if (parsedDate == null) return null;

    final parsedTime = _parseTimeParts(timeValue);
    final hour = parsedTime?[0] ?? (endOfDayWhenTimeMissing ? 23 : 0);
    final minute = parsedTime?[1] ?? (endOfDayWhenTimeMissing ? 59 : 0);

    return DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      hour,
      minute,
    );
  }

  static List<int>? _parseTimeParts(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final parts = trimmed.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return [hour, minute];
  }

  @override
  List<Object?> get props => [
    id,
    title,
    imageUrl,
    isActive,
    sortOrder,
    displaySeconds,
    targetCategory,
    targetVenueId,
    targetVenueName,
    targetOfferId,
    targetOfferTitle,
    targetOfferDate,
    startDate,
    startTime,
    endDate,
    endTime,
    createdAt,
    updatedAt,
  ];
}
