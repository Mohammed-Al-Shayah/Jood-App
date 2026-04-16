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
  final DateTime createdAt;
  final DateTime updatedAt;

  int get resolvedDisplaySeconds => displaySeconds.clamp(1, 10);

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
    createdAt,
    updatedAt,
  ];
}
