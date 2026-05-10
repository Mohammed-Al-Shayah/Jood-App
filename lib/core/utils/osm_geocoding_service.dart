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

    final results = <OsmPlaceResult>[];
    final seenKeys = <String>{};
    for (final queryVariant in _searchQueryVariants(normalizedQuery)) {
      final response = await _sendSearchRequest(
        queryVariant,
        limit: limit,
        languageCode: languageCode,
        countryCode: normalizedCountryCode,
      );
      final variantResults = _parseSearchResults(response.body);
      for (final result in variantResults) {
        final key = _resultKey(result);
        if (seenKeys.add(key)) {
          results.add(result);
        }
      }
      if (results.length >= limit) break;
    }

    final limitedResults = results.take(limit).toList(growable: false);
    _searchCache[cacheKey] = limitedResults;
    return limitedResults;
  }

  static Future<http.Response> _sendSearchRequest(
    String query, {
    required int limit,
    required String languageCode,
    required String countryCode,
  }) {
    final uri = Uri.https(_host, '/search', {
      'q': query,
      'format': 'jsonv2',
      'addressdetails': '1',
      'limit': limit.toString(),
      'accept-language': languageCode,
      if (countryCode.isNotEmpty) 'countrycodes': countryCode,
    });
    return _sendRequest(uri);
  }

  static List<OsmPlaceResult> _parseSearchResults(String body) {
    final decoded = jsonDecode(body);
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

    return results;
  }

  static List<String> _searchQueryVariants(String query) {
    final variants = <String>[];
    void add(String value) {
      final normalized = _normalizeQuerySpacing(value);
      if (normalized.isEmpty) return;
      if (!variants.any(
        (item) => item.toLowerCase() == normalized.toLowerCase(),
      )) {
        variants.add(normalized);
      }
    }

    add(query);
    add(_expandStreetAbbreviations(query));
    add(_removeStreetTypeWords(query));

    final parts = query
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.length >= 2) {
      add(parts.take(2).join(', '));
      add(parts.skip(1).join(', '));
      add(parts.first);
    }

    return variants.take(5).toList(growable: false);
  }

  static String _normalizeQuerySpacing(String value) {
    final buffer = StringBuffer();
    var previousWasSpace = false;
    for (final codeUnit in value.trim().codeUnits) {
      final char = String.fromCharCode(codeUnit);
      final isSpace = char.trim().isEmpty;
      if (isSpace) {
        if (!previousWasSpace) {
          buffer.write(' ');
        }
      } else {
        buffer.write(char);
      }
      previousWasSpace = isSpace;
    }
    return buffer
        .toString()
        .replaceAll(' ,', ',')
        .replaceAll(',,', ',')
        .trim();
  }

  static String _expandStreetAbbreviations(String query) {
    return _mapQueryWords(query, (word) {
      final normalized = _plainWord(word).toLowerCase();
      if (normalized == 'st') return 'Street${_wordSuffix(word)}';
      if (normalized == 'rd') return 'Road${_wordSuffix(word)}';
      if (normalized == 'ave') return 'Avenue${_wordSuffix(word)}';
      return word;
    });
  }

  static String _removeStreetTypeWords(String query) {
    return _mapQueryWords(query, (word) {
      final normalized = _plainWord(word).toLowerCase();
      const streetTypes = {'street', 'st', 'road', 'rd', 'avenue', 'ave'};
      return streetTypes.contains(normalized) ? _wordSuffix(word) : word;
    });
  }

  static String _mapQueryWords(
    String query,
    String Function(String word) transform,
  ) {
    return _normalizeQuerySpacing(
      query.split(' ').map(transform).join(' '),
    );
  }

  static String _plainWord(String word) {
    return word
        .replaceAll(',', '')
        .replaceAll('.', '')
        .replaceAll(':', '')
        .replaceAll(';', '')
        .trim();
  }

  static String _wordSuffix(String word) {
    if (word.endsWith(',')) return ',';
    if (word.endsWith('.')) return '.';
    return '';
  }

  static String _resultKey(OsmPlaceResult result) {
    final lat = result.point.latitude.toStringAsFixed(5);
    final lng = result.point.longitude.toStringAsFixed(5);
    return '$lat|$lng|${result.displayName.toLowerCase()}';
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
