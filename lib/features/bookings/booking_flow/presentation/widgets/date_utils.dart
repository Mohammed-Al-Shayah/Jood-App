import 'package:intl/intl.dart';

import '../../../../../core/localization/app_localization_controller.dart';

String formatOfferDate(DateTime date) {
  return DateFormat(
    'EEE, MMM d',
    AppLocalizationController.instance.localeName,
  ).format(date);
}

String weekdayShort(int weekday) {
  final date = DateTime(2026, 1, weekday + 4);
  return DateFormat(
    'EEE',
    AppLocalizationController.instance.localeName,
  ).format(date);
}

String monthShort(int month) {
  final date = DateTime(2026, month, 1);
  return DateFormat(
    'MMM',
    AppLocalizationController.instance.localeName,
  ).format(date);
}
