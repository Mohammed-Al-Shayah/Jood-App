import 'package:jood/core/utils/app_strings.dart';

bool usesUnifiedGuestCount(String bookableType) {
  return bookableType.trim().toLowerCase() == 'attraction';
}

String buildGuestsLabel(
  int adultsCount,
  int childrenCount, {
  String bookableType = '',
}) {
  if (usesUnifiedGuestCount(bookableType)) {
    return AppStrings.guestsCountLabel(adultsCount + childrenCount);
  }
  if (childrenCount > 0) {
    return '${AppStrings.adultsCountLabel(adultsCount)} | ${AppStrings.childrenCountLabel(childrenCount)}';
  }
  return AppStrings.adultsCountLabel(adultsCount);
}
