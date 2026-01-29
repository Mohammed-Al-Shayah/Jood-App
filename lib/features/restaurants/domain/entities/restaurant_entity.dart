import 'package:equatable/equatable.dart';

class RestaurantEntity extends Equatable {
  const RestaurantEntity({
    required this.id,
    required this.name,
    required this.cityId,
    required this.area,
    required this.rating,
    required this.reviewsCount,
    required this.coverImageUrl,
    required this.about,
    required this.phone,
    required this.address,
    required this.geoLat,
    required this.geoLng,
    required this.openFrom,
    required this.openTo,
    required this.highlights,
    required this.inclusions,
    required this.exclusions,
    required this.cancellationPolicy,
    required this.knowBeforeYouGo,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String cityId;
  final String area;
  final double rating;
  final int reviewsCount;
  final String coverImageUrl;
  final String about;
  final String phone;
  final String address;
  final double geoLat;
  final double geoLng;
  final String openFrom;
  final String openTo;
  final List<String> highlights;
  final List<String> inclusions;
  final List<String> exclusions;
  final List<String> cancellationPolicy;
  final List<String> knowBeforeYouGo;
  final bool isActive;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        name,
        cityId,
        area,
        rating,
        reviewsCount,
        coverImageUrl,
        about,
        phone,
        address,
        geoLat,
        geoLng,
        openFrom,
        openTo,
        highlights,
        inclusions,
        exclusions,
        cancellationPolicy,
        knowBeforeYouGo,
        isActive,
        createdAt,
      ];
}
