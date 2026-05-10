class AppAuthException implements Exception {
  const AppAuthException({required this.code, this.message, this.details});

  final String code;
  final String? message;
  final Map<String, dynamic>? details;
}

int? authRetryAfterSeconds(Object error) {
  final details = switch (error) {
    AppAuthException(details: final details) => details,
    _ => null,
  };
  if (details == null) {
    return null;
  }

  final retryAfter = details['retryAfterSeconds'];
  if (retryAfter is int && retryAfter > 0) {
    return retryAfter;
  }
  if (retryAfter is num && retryAfter > 0) {
    return retryAfter.ceil();
  }
  if (retryAfter is String) {
    final parsed = int.tryParse(retryAfter);
    if (parsed != null && parsed > 0) {
      return parsed;
    }
  }

  return null;
}
 