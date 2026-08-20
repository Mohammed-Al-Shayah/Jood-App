class ThawaniConfig {
  const ThawaniConfig._();

  static const String apiKey = String.fromEnvironment(
    'THAWANI_API_KEY',

    // defaultValue: 'rRQ26GcsZzoEhbrP2HZvLYDbn9C9et',
    defaultValue: 'd8VN7G0S3thJ6mm73GA6IDGeg9PBYp',
  );

  static const String publishableApiKey = String.fromEnvironment(
    'THAWANI_PUBLISHABLE_KEY',
    defaultValue: 'i5I5UCV4s4qoSTOSqmiwdo9h1OGVGI',
    // defaultValue: 'HGvTMLDssJghr9tlN9gr4DVYt0qyBy',
  );

  static const bool isTestMode =
      String.fromEnvironment('THAWANI_TEST_MODE', defaultValue: 'false') ==
      'false';

  static bool get isConfigured =>
      apiKey.isNotEmpty && publishableApiKey.isNotEmpty;
}
