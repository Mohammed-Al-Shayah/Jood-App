import 'dart:convert';

class ThawaniSessionParser {
  const ThawaniSessionParser._();

  static String? extractSessionId(dynamic value) {
    if (value == null) return null;

    try {
      final dynamic data = (value as dynamic).data;
      if (data is Map) {
        return data['session_id']?.toString() ?? data['sessionId']?.toString();
      }
      if (data != null) {
        try {
          final sessionId = (data as dynamic).sessionId;
          if (sessionId != null) return sessionId.toString();
        } catch (_) {}
        try {
          final sessionId = (data as dynamic).session_id;
          if (sessionId != null) return sessionId.toString();
        } catch (_) {}
      }
    } catch (_) {}

    if (value is Map) {
      return _searchInMap(value);
    }

    try {
      final decoded = jsonDecode(jsonEncode(value));
      if (decoded is Map) {
        return _searchInMap(decoded);
      }
    } catch (_) {}

    return null;
  }

  static String? _searchInMap(dynamic map) {
    if (map is! Map) return null;
    final castedMap = Map<String, dynamic>.from(map);
    final rootId =
        castedMap['session_id']?.toString() ??
        castedMap['sessionId']?.toString() ??
        castedMap['id']?.toString();
    if (rootId != null) return rootId;

    final data = castedMap['data'];
    if (data is! Map) return null;
    final nested = Map<String, dynamic>.from(data);
    return nested['session_id']?.toString() ??
        nested['sessionId']?.toString() ??
        nested['id']?.toString();
  }
}
