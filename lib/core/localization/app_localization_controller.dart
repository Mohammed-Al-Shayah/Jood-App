import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizationController {
  AppLocalizationController._();

  static final AppLocalizationController instance =
      AppLocalizationController._();

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ar')];
  static const Locale fallbackLocale = Locale('en');
  static const String _languageCodePreferenceKey = 'app_language_code';

  final ValueNotifier<Locale> localeNotifier = ValueNotifier<Locale>(
    fallbackLocale,
  );

  Map<String, dynamic> _localizedValues = const <String, dynamic>{};
  Map<String, dynamic> _fallbackValues = const <String, dynamic>{};
  bool _isInitialized = false;

  Locale get locale => localeNotifier.value;
  String get localeName => locale.languageCode;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await initializeDateFormatting('en');
    await initializeDateFormatting('ar');

    _fallbackValues = await _loadTranslations(fallbackLocale);

    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString(_languageCodePreferenceKey);
    final initialLocale = savedLanguageCode == null
        ? resolveSupportedLocale(PlatformDispatcher.instance.locale)
        : resolveSupportedLocale(Locale(savedLanguageCode));

    await _applyLocale(initialLocale, persist: false);
    _isInitialized = true;
  }

  Future<void> setLocale(Locale locale) async {
    await _applyLocale(resolveSupportedLocale(locale));
  }

  Future<void> toggleLocale() async {
    await setLocale(
      locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar'),
    );
  }

  Locale resolveSupportedLocale(Locale? requestedLocale) {
    if (requestedLocale == null) return fallbackLocale;
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == requestedLocale.languageCode,
      orElse: () => fallbackLocale,
    );
  }

  String tr(
    String key, {
    Map<String, Object?> params = const <String, Object?>{},
    String? fallback,
  }) {
    final rawValue =
        _localizedValues[key] ?? _fallbackValues[key] ?? fallback ?? key;
    if (rawValue is! String) {
      return fallback ?? key;
    }

    var translated = rawValue;
    params.forEach((placeholder, value) {
      translated = translated.replaceAll(
        '{$placeholder}',
        value?.toString() ?? '',
      );
    });
    return translated;
  }

  List<String> trList(String key) {
    final rawValue = _localizedValues[key] ?? _fallbackValues[key];
    if (rawValue is! List) return const <String>[];
    return rawValue.map((item) => item.toString()).toList(growable: false);
  }

  Future<void> _applyLocale(Locale locale, {bool persist = true}) async {
    final resolvedLocale = resolveSupportedLocale(locale);
    _localizedValues = await _loadTranslations(resolvedLocale);
    Intl.defaultLocale = resolvedLocale.languageCode;
    localeNotifier.value = resolvedLocale;

    if (!persist) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _languageCodePreferenceKey,
      resolvedLocale.languageCode,
    );
  }

  Future<Map<String, dynamic>> _loadTranslations(Locale locale) async {
    final jsonString = await rootBundle.loadString(
      'assets/translations/${locale.languageCode}.json',
    );
    final decoded = jsonDecode(jsonString);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return const <String, dynamic>{};
  }
}
