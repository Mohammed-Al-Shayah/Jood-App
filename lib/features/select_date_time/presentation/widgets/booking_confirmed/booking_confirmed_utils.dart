import '../../../../../core/utils/app_strings.dart';

String buildGuestsLabel(int adultsCount, int childrenCount) {
  if (childrenCount > 0) {
    return '$adultsCount ${AppStrings.adults}, $childrenCount ${AppStrings.children}';
  }
  return '$adultsCount ${AppStrings.adults}';
}
