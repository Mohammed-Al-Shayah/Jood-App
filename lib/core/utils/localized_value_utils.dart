import '../localization/app_localization_controller.dart';

String resolveLocalizedText({
  required String english,
  String arabic = '',
  String fallback = '',
}) {
  final englishValue = english.trim();
  final arabicValue = arabic.trim();
  final fallbackValue = fallback.trim();
  final prefersArabic = AppLocalizationController.instance.localeName == 'ar';

  if (prefersArabic) {
    if (arabicValue.isNotEmpty) return arabicValue;
    if (englishValue.isNotEmpty) return englishValue;
  } else {
    if (englishValue.isNotEmpty) return englishValue;
    if (arabicValue.isNotEmpty) return arabicValue;
  }

  return fallbackValue;
}

List<String> resolveLocalizedList({
  required List<String> english,
  List<String> arabic = const [],
  List<String> fallback = const [],
}) {
  final englishValues = _cleanList(english);
  final arabicValues = _cleanList(arabic);
  final fallbackValues = _cleanList(fallback);
  final prefersArabic = AppLocalizationController.instance.localeName == 'ar';

  if (prefersArabic) {
    if (arabicValues.isNotEmpty) return arabicValues;
    if (englishValues.isNotEmpty) return englishValues;
  } else {
    if (englishValues.isNotEmpty) return englishValues;
    if (arabicValues.isNotEmpty) return arabicValues;
  }

  return fallbackValues;
}

List<String> _cleanList(List<String> values) {
  return values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
}
