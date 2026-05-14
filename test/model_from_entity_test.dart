import 'package:flutter_test/flutter_test.dart';
import 'package:jood/features/ads/data/models/ad_model.dart';
import 'package:jood/features/ads/domain/entities/ad_entity.dart';
import 'package:jood/features/offers/data/models/offer_model.dart';
import 'package:jood/features/offers/domain/entities/offer_entity.dart';

void main() {
  group('AdModel.fromEntity', () {
    test('copies entity values into a data model', () {
      final now = DateTime(2026, 1, 2, 3, 4);
      final entity = AdEntity(
        id: 'ad-1',
        title: 'Home banner',
        imageUrl: 'https://example.com/banner.png',
        isActive: true,
        sortOrder: 2,
        displaySeconds: 5,
        targetCategory: 'buffet',
        targetVenueId: 'venue-1',
        targetVenueName: 'Venue',
        targetOfferId: 'offer-1',
        targetOfferTitle: 'Offer',
        targetOfferDate: '2026-01-03',
        startDate: '2026-01-02',
        startTime: '10:00',
        endDate: '2026-01-04',
        endTime: '12:00',
        createdAt: now,
        updatedAt: now,
      );

      final model = AdModel.fromEntity(entity);

      expect(model, isA<AdModel>());
      expect(model.id, entity.id);
      expect(model.title, entity.title);
      expect(model.toMap()['displaySeconds'], entity.displaySeconds);
    });
  });

  group('OfferModel.fromEntity', () {
    test('copies entity values into a data model', () {
      final now = DateTime(2026, 1, 2, 3, 4);
      final entity = OfferEntity(
        id: 'offer-1',
        restaurantId: 'venue-1',
        date: '2026-01-03',
        startTime: '10:00',
        endTime: '12:00',
        currency: 'OMR',
        priceAdult: 20,
        priceAdultOriginal: 30,
        priceChild: 10,
        capacityAdult: 8,
        capacityChild: 4,
        bookedAdult: 1,
        bookedChild: 2,
        status: 'active',
        title: 'Lunch',
        entryConditions: const ['Bring ID'],
        createdAt: now,
        updatedAt: now,
        bookingCategory: 'set_menu',
        mealType: 'lunch',
        titleEn: 'Lunch',
        titleAr: 'Lunch AR',
      );

      final model = OfferModel.fromEntity(entity);

      expect(model, isA<OfferModel>());
      expect(model.id, entity.id);
      expect(model.bookingCategory, entity.bookingCategory);
      expect(model.toMap()['title'], entity.titleEn);
      expect(model.toMap()['titleAr'], entity.titleAr);
    });
  });
}
