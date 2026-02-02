import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'date_chip.dart';
import 'more_chip.dart';
import 'package:jood/core/utils/date_utils.dart';

class DateStrip extends StatelessWidget {
  const DateStrip({
    super.key,
    required this.dates,
    required this.selectedIndex,
    required this.onDateTap,
    required this.onMoreTap,
    required this.datePrices,
    required this.currency,
  });

  final List<DateTime> dates;
  final int selectedIndex;
  final ValueChanged<int> onDateTap;
  final VoidCallback onMoreTap;
  final Map<String, double> datePrices;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: dates.length + 1,
      separatorBuilder: (_, _) => SizedBox(width: 10.w),
      itemBuilder: (context, index) {
        if (index == dates.length) {
          return MoreChip(
            isSelected: selectedIndex == dates.length,
            onTap: onMoreTap,
          );
        }
        final date = dates[index];
        final key = AppDateUtils.formatDate(date);
        final price = datePrices[key];
        return DateChip(
          date: date,
          isSelected: selectedIndex == index,
          onTap: () => onDateTap(index),
          price: price,
          currency: currency,
        );
      },
    );
  }
}


