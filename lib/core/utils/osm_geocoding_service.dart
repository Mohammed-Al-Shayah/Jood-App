import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OsmGeocodingException implements Exception {
  const OsmGeocodingException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OsmPlaceResult {
  const OsmPlaceResult({
    required this.point,
    required this.displayName,
    required this.addressParts,
  });

  final LatLng point;
  final String displayName;
  final Map<String, String> addressParts;

  String get country => addressParts['country'] ?? '';
  String get countryCode => addressParts['country_code'] ?? '';
  String get city =>
      addressParts['city'] ??
      addressParts['town'] ??
      addressParts['village'] ??
      addressParts['municipality'] ??
      '';

  factory OsmPlaceResult.fromJson(Map<String, dynamic> json) {
    final lat = double.tryParse(json['lat']?.toString() ?? '');
    final lng = double.tryParse(json['lon']?.toString() ?? '');
    if (lat == null || lng == null) {
      throw const OsmGeocodingException('Invalid coordinates in response.');
    }

    final address = <String, String>{};
    final rawAddress = json['address'];
    if (rawAddress is Map) {
      for (final entry in rawAddress.entries) {
        final key = entry.key.toString().trim();
        final value = entry.value.toString().trim();
        if (key.isEmpty || value.isEmpty) continue;
        address[key] = value;
      }
    }

    return OsmPlaceResult(
      point: LatLng(lat, lng),
      displayName: (json['display_name']?.toString() ?? '').trim(),
      addressParts: address,
    );
  }
}

class OsmGeocodingService {
  static const String _host = 'nominatim.openstreetmap.org';
  static const String _userAgent =
      'jood-admin-dashboard/1.0 (support@jood.app)';
  static const Duration _minRequestInterval = Duration(milliseconds: 1100);
  static const Duration _requestTimeout = Duration(seconds: 12);

  static DateTime? _lastRequestAt;
  static final Map<String, List<OsmPlaceResult>> _searchCache = {};
  static final Map<String, OsmPlaceResult> _reverseCache = {};

  static Future<List<OsmPlaceResult>> searchPlaces(
    String query, {
    int limit = 5,
    String languageCode = 'en',
    String countryCode = 'om',
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return const [];

    final normalizedCountryCode = countryCode.trim().toLowerCase();
    final cacheKey =
        '${normalizedQuery.toLowerCase()}|$limit|$languageCode|$normalizedCountryCode';
    final cached = _searchCache[cacheKey];
    if (cached != null) return cached;

    final uri = Uri.https(_host, '/search', {
      'q': normalizedQuery,
      'format': 'jsonv2',
      'addressdetails': '1',
      'limit': limit.toString(),
      'accept-language': languageCode,
      if (normalizedCountryCode.isNotEmpty)
        'countrycodes': normalizedCountryCode,
    });

    final response = await _sendRequest(uri);
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const OsmGeocodingException('Unexpected search response format.');
    }

    final results = <OsmPlaceResult>[];
    for (final raw in decoded) {
      if (raw is! Map) continue;
      try {
        results.add(OsmPlaceResult.fromJson(Map<String, dynamic>.from(raw)));
      } on OsmGeocodingException {
        continue;
      }
    }

    _searchCache[cacheKey] = results;
    return results;
  }

  static Future<OsmPlaceResult?> reverseGeocode(
    LatLng point, {
    String languageCode = 'en',
  }) async {
    final lat = point.latitude.toStringAsFixed(6);
    final lng = point.longitude.toStringAsFixed(6);
    final cacheKey = '$lat|$lng|$languageCode';
    final cached = _reverseCache[cacheKey];
    if (cached != null) return cached;

    final uri = Uri.https(_host, '/reverse', {
      'lat': lat,
      'lon': lng,
      'format': 'jsonv2',
      'addressdetails': '1',
      'zoom': '18',
      'accept-language': languageCode,
    });

    final response = await _sendRequest(uri);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const OsmGeocodingException('Unexpected reverse response format.');
    }
    final mapped = Map<String, dynamic>.from(decoded);
    if (mapped.containsKey('error')) return null;

    final result = OsmPlaceResult.fromJson(mapped);
    _reverseCache[cacheKey] = result;
    return result;
  }

  static Future<http.Response> _sendRequest(Uri uri) async {
    await _respectRateLimit();

    try {
      final response = await http
          .get(uri, headers: const {'User-Agent': _userAgent})
          .timeout(_requestTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw OsmGeocodingException(
          'Geocoding request failed (${response.statusCode}).',
        );
      }
      return response;
    } on TimeoutException {
      throw const OsmGeocodingException('Geocoding request timed out.');
    } on OsmGeocodingException {
      rethrow;
    } catch (_) {
      throw const OsmGeocodingException('Geocoding request failed.');
    }
  }

  static Future<void> _respectRateLimit() async {
    final lastCallAt = _lastRequestAt;
    if (lastCallAt != null) {
      final elapsed = DateTime.now().difference(lastCallAt);
      if (elapsed < _minRequestInterval) {
        await Future<void>.delayed(_minRequestInterval - elapsed);
      }
    }
    _lastRequestAt = DateTime.now();
  }
}
