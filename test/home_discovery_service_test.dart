import 'package:flutter_test/flutter_test.dart';
import 'package:jood/features/booking_catalog/domain/entities/catalog_category_type.dart';
import 'package:jood/features/booking_catalog/domain/entities/catalog_item_entity.dart';
import 'package:jood/features/home/presentation/utils/home_discovery_service.dart';

void main() {
  final service = HomeDiscoveryService(
    distanceBetween: (startLat, startLng, endLat, endLng) {
      final latDelta = startLat - endLat;
      final lngDelta = startLng - endLng;
      return (latDelta * latDelta) + (lngDelta * lngDelta);
    },
  );

  group('HomeDiscoveryService', () {
    test('formats location labels', () {
      expect(service.locationLabel('Muscat', 'Oman'), 'Muscat, Oman');
      expect(service.locationLabel('', 'Oman'), 'Oman');
      expect(service.locationLabel('Muscat', ''), 'Muscat');
    });

    test('normalizes display prices', () {
      expect(service.stripFromPrice('From OMR 12'), 'OMR 12');
      expect(service.normalizeDisplayedPrice('OMR 12'), 'OMR 12.0');
    });

    test('ranks hot deals by discount score', () {
      final items = [
        _item(id: 'low', badge: '10% off'),
        _item(id: 'high', badge: '35% off'),
        _item(id: 'none', badge: '', discount: ''),
      ];

      final deals = service.hotDeals(items);

      expect(deals.map((item) => item.id), ['high', 'low']);
    });

    test('ranks nearby items by coordinates when location is available', () {
      final items = [
        _item(id: 'far', geoLat: 10, geoLng: 10),
        _item(id: 'near', geoLat: 1, geoLng: 1),
      ];

      final nearby = service.nearbyItems(
        items,
        userLatitude: 0,
        userLongitude: 0,
      );

      expect(nearby.map((item) => item.id), ['near', 'far']);
    });

    test(
      'matches nearby items by city text when coordinates are unavailable',
      () {
        final items = [
          _item(id: 'matched', cityId: 'Muscat', rating: 3),
          _item(id: 'unmatched', cityId: 'Salalah', rating: 5),
        ];

        final nearby = service.nearbyItems(items, userCity: 'muscat');

        expect(nearby.map((item) => item.id), ['matched']);
      },
    );
  });
}

CatalogItemEntity _item({
  required String id,
  String cityId = 'City',
  String area = 'Area',
  String badge = '',
  String priceFrom = r'$100',
  String discount = r'$80',
  String slotsLeft = '5 slots',
  double rating = 4,
  double geoLat = 0,
  double geoLng = 0,
}) {
  return CatalogItemEntity(
    id: id,
    category: CatalogCategoryType.buffet,
    bookingMode: CatalogCategoryType.buffet.bookingMode,
    sourceCollection: 'restaurants',
    name: id,
    cityId: cityId,
    area: area,
    address: '$area, $cityId',
    rating: rating,
    reviewsCount: 0,
    coverImageUrl: '',
    description: '',
    highlights: const [],
    inclusions: const [],
    availableMeals: const [],
    packageOverview: const [],
    bookingNotes: const [],
    geoLat: geoLat,
    geoLng: geoLng,
    requiresMenuItemSelection: false,
    badge: badge,
    priceFrom: priceFrom,
    discount: discount,
    slotsLeft: slotsLeft,
    isActive: true,
  );
}
