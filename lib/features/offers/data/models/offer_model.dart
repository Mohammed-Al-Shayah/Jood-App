import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/localized_value_utils.dart';
import '../../../../core/utils/number_utils.dart';
import '../../domain/entities/offer_entity.dart';

class OfferModel extends OfferEntity {
  const OfferModel({
    required super.id,
    required super.restaurantId,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.currency,
    required super.priceAdult,
    required super.priceAdultOriginal,
    required super.priceChild,
    required super.capacityAdult,
    required super.capacityChild,
    required super.bookedAdult,
    required super.bookedChild,
    required super.status,
    required super.title,
    required super.entryConditions,
    required super.createdAt,
    required super.updatedAt,
    super.bookingCategory,
    super.bookableType,
    super.mealType,
    super.packageName,
    super.packageDescription,
    super.titleEn,
    super.titleAr,
    super.entryConditionsEn,
    super.entryConditionsAr,
    super.packageNameEn,
    super.packageNameAr,
    super.packageDescriptionEn,
    super.packageDescriptionAr,
  });

  factory OfferModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final titleEn = (data['title'] as String? ?? '').trim();
    final titleAr = (data['titleAr'] as String? ?? '').trim();
    final entryConditionsEn = _stringList(data['entryConditions']);
    final entryConditionsAr = _stringList(data['entryConditionsAr']);
    final packageNameEn = (data['packageName'] as String? ?? '').trim();
    final packageNameAr = (data['packageNameAr'] as String? ?? '').trim();
    final packageDescriptionEn = (data['packageDescription'] as String? ?? '')
        .trim();
    final packageDescriptionAr = (data['packageDescriptionAr'] as String? ?? '')
        .trim();

    return OfferModel(
      id: doc.id,
      restaurantId: data['restaurantId'] as String? ?? '',
      date: _readDate(data['date']),
      startTime: data['startTime'] as String? ?? '',
      endTime: data['endTime'] as String? ?? '',
      currency: data['currency'] as String? ?? 'USD',
      priceAdult: NumberUtils.toDouble(data['priceAdult']),
      priceAdultOriginal: NumberUtils.toDouble(data['priceAdultOriginal']),
      priceChild: NumberUtils.toDouble(data['priceChild']),
      capacityAdult: (data['capacityAdult'] as num?)?.toInt() ?? 0,
      capacityChild: (data['capacityChild'] as num?)?.toInt() ?? 0,
      bookedAdult: (data['bookedAdult'] as num?)?.toInt() ?? 0,
      bookedChild: (data['bookedChild'] as num?)?.toInt() ?? 0,
      status: data['status'] as String? ?? 'active',
      title: resolveLocalizedText(english: titleEn, arabic: titleAr),
      entryConditions: resolveLocalizedList(
        english: entryConditionsEn,
        arabic: entryConditionsAr,
      ),
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
      bookingCategory: data['bookingCategory'] as String? ?? '',
      bookableType: data['bookableType'] as String? ?? 'restaurant',
      mealType: data['mealType'] as String? ?? '',
      packageName: resolveLocalizedText(
        english: packageNameEn,
        arabic: packageNameAr,
      ),
      packageDescription: resolveLocalizedText(
        english: packageDescriptionEn,
        arabic: packageDescriptionAr,
      ),
      titleEn: titleEn,
      titleAr: titleAr,
      entryConditionsEn: entryConditionsEn,
      entryConditionsAr: entryConditionsAr,
      packageNameEn: packageNameEn,
      packageNameAr: packageNameAr,
      packageDescriptionEn: packageDescriptionEn,
      packageDescriptionAr: packageDescriptionAr,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'restaurantId': restaurantId,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'currency': currency,
      'priceAdult': priceAdult,
      'priceAdultOriginal': priceAdultOriginal,
      'priceChild': priceChild,
      'capacityAdult': capacityAdult,
      'capacityChild': capacityChild,
      'bookedAdult': bookedAdult,
      'bookedChild': bookedChild,
      'status': status,
      'title': _baseText(titleEn, title),
      'titleAr': titleAr.trim(),
      'entryConditions': _baseList(entryConditionsEn, entryConditions),
      'entryConditionsAr': _cleanList(entryConditionsAr),
      'bookingCategory': bookingCategory,
      'bookableType': bookableType,
      'mealType': mealType,
      'packageName': _baseText(packageNameEn, packageName),
      'packageNameAr': packageNameAr.trim(),
      'packageDescription': _baseText(packageDescriptionEn, packageDescription),
      'packageDescriptionAr': packageDescriptionAr.trim(),
    };
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }
    return const [];
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  static String _readDate(dynamic value) {
    if (value is Timestamp) {
      return AppDateUtils.formatDate(value.toDate());
    }
    if (value is DateTime) {
      return AppDateUtils.formatDate(value);
    }
    if (value == null) return '';
    return value.toString();
  }

  static String _baseText(String rawEnglish, String fallback) {
    final english = rawEnglish.trim();
    if (english.isNotEmpty) return english;
    return fallback.trim();
  }

  static List<String> _baseList(
    List<String> rawEnglish,
    List<String> fallback,
  ) {
    final english = _cleanList(rawEnglish);
    if (english.isNotEmpty) return english;
    return _cleanList(fallback);
  }

  static List<String> _cleanList(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }
}
