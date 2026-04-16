import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/ad_entity.dart';

class AdModel extends AdEntity {
  const AdModel({
    required super.id,
    required super.title,
    required super.imageUrl,
    required super.isActive,
    required super.sortOrder,
    required super.displaySeconds,
    required super.targetCategory,
    required super.targetVenueId,
    required super.targetVenueName,
    required super.targetOfferId,
    required super.targetOfferTitle,
    required super.targetOfferDate,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AdModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return AdModel(
      id: doc.id,
      title: (data['title'] as String? ?? '').trim(),
      imageUrl: (data['imageUrl'] as String? ?? '').trim(),
      isActive: data['isActive'] as bool? ?? true,
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      displaySeconds: (data['displaySeconds'] as num?)?.toInt() ?? 3,
      targetCategory: (data['targetCategory'] as String? ?? '').trim(),
      targetVenueId: (data['targetVenueId'] as String? ?? '').trim(),
      targetVenueName: (data['targetVenueName'] as String? ?? '').trim(),
      targetOfferId: (data['targetOfferId'] as String? ?? '').trim(),
      targetOfferTitle: (data['targetOfferTitle'] as String? ?? '').trim(),
      targetOfferDate: (data['targetOfferDate'] as String? ?? '').trim(),
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title.trim(),
      'imageUrl': imageUrl.trim(),
      'isActive': isActive,
      'sortOrder': sortOrder,
      'displaySeconds': resolvedDisplaySeconds,
      'targetCategory': targetCategory.trim(),
      'targetVenueId': targetVenueId.trim(),
      'targetVenueName': targetVenueName.trim(),
      'targetOfferId': targetOfferId.trim(),
      'targetOfferTitle': targetOfferTitle.trim(),
      'targetOfferDate': targetOfferDate.trim(),
    };
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
