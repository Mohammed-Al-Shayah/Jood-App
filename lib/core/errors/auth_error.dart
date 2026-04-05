class AppAuthException implements Exception {
  const AppAuthException({required this.code, this.message});

  final String code;
  final String? message;
}
