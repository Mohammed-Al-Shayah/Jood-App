class TurnstileConfig {
  const TurnstileConfig._();

  static const String siteKey = String.fromEnvironment(
    'TURNSTILE_SITE_KEY',
    defaultValue: '0x4AAAAAADIZz09kQBgo6TEn',
  );

  static const String baseUrl = String.fromEnvironment(
    'TURNSTILE_BASE_URL',
    defaultValue: 'https://joodapp-3051e.web.app/',
  );

  static bool get isConfigured => siteKey.trim().isNotEmpty;
}
