import 'package:flutter_test/flutter_test.dart';
import 'package:jood/core/utils/osm_geocoding_service.dart';

void main() {
  group('OsmGeocodingService.tryParseCoordinates', () {
    test('parses comma-separated latitude and longitude', () {
      final point = OsmGeocodingService.tryParseCoordinates(
        '31.5142581264923, 34.4311443658844',
      );

      expect(point, isNotNull);
      expect(point!.latitude, 31.5142581264923);
      expect(point.longitude, 34.4311443658844);
    });

    test('parses Arabic comma-separated latitude and longitude', () {
      final point = OsmGeocodingService.tryParseCoordinates('23.588، 58.3829');

      expect(point, isNotNull);
      expect(point!.latitude, 23.588);
      expect(point.longitude, 58.3829);
    });

    test('parses space-separated latitude and longitude', () {
      final point = OsmGeocodingService.tryParseCoordinates('23.588 58.3829');

      expect(point, isNotNull);
      expect(point!.latitude, 23.588);
      expect(point.longitude, 58.3829);
    });

    test('rejects invalid coordinates and normal place text', () {
      expect(OsmGeocodingService.tryParseCoordinates('91, 58'), isNull);
      expect(OsmGeocodingService.tryParseCoordinates('Muscat Mall'), isNull);
    });
  });
}
