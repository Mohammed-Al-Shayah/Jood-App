import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';

class CalendarSheet extends StatefulWidget {
  const CalendarSheet({
    super.key,
    required this.initialMonth,
    required this.selectedDate,
    required this.monthCount,
    required this.currency,
    required this.pricesLoader,
  });

  final DateTime initialMonth;
  final DateTime selectedDate;
  final int monthCount;
  final String currency;
  final Future<Map<String, double>> Function(DateTime month) pricesLoader;

  @override
  State<CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<CalendarSheet> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(
      widget.initialMonth.year,
      widget.initialMonth.month,
      1,
    );
  }

  void _goNextMonth() {
    final next = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    setState(() => _currentMonth = next);
  }

  void _goPrevMonth() {
    final prev = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    if (_isBeforeMin(prev)) return;
    setState(() => _currentMonth = prev);
  }

  bool _isBeforeMin(DateTime month) {
    final min = DateTime(
      widget.initialMonth.year,
      widget.initialMonth.month,
      1,
    );
    return month.isBefore(min);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height * 0.75),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.shadowColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Select date',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 16.sp),
              ),
              SizedBox(height: 12.h),
              FutureBuilder<Map<String, double>>(
                future: widget.pricesLoader(_currentMonth),
                builder: (context, snapshot) {
                  final prices = snapshot.data ?? const {};
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (snapshot.connectionState == ConnectionState.waiting)
                        LinearProgressIndicator(
                          minHeight: 3.h,
                          color: AppColors.primary,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.12,
                          ),
                        ),
                      _MonthSection(
                        month: _currentMonth,
                        selectedDate: widget.selectedDate,
                        currency: widget.currency,
                        prices: prices,
                        onSelect: (date) => Navigator.of(context).pop(date),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isBeforeMin(
                            DateTime(
                              _currentMonth.year,
                              _currentMonth.month - 1,
                              1,
                            ),
                          )
                          ? null
                          : _goPrevMonth,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Previous',
                        style: AppTextStyles.cardTitle.copyWith(
                          color: AppColors.primary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _goNextMonth,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Next',
                        style: AppTextStyles.cardTitle.copyWith(
                          color: AppColors.primary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthSection extends StatelessWidget {
  const _MonthSection({
    required this.month,
    required this.selectedDate,
    required this.currency,
    required this.prices,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selectedDate;
  final String currency;
  final Map<String, double> prices;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final totalCells = ((firstWeekday + daysInMonth + 6) ~/ 7) * 7;
    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        Text(
          _monthLabel(month),
          style: AppTextStyles.cardTitle.copyWith(fontSize: 16.sp),
        ),
        SizedBox(height: 10.h),
        _WeekdaysRow(),
        SizedBox(height: 6.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalCells,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final dayNumber = index - firstWeekday + 1;
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox.shrink();
            }
            final date = DateTime(month.year, month.month, dayNumber);
            final isSelected = _isSameDay(date, selectedDate);
            final isPast = date.isBefore(
              DateTime(today.year, today.month, today.day),
            );
            final price = prices[_formatDate(date)];

            return _DayCell(
              day: dayNumber,
              isSelected: isSelected,
              isDisabled: isPast,
              price: price,
              currency: currency,
              onTap: isPast ? null : () => onSelect(date),
            );
          },
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}

class _WeekdaysRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      children: labels
          .map(
            (label) => Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.cardMeta.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isDisabled,
    required this.price,
    required this.currency,
    required this.onTap,
  });

  final int day;
  final bool isSelected;
  final bool isDisabled;
  final double? price;
  final String currency;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dayStyle = AppTextStyles.cardMeta.copyWith(
      fontWeight: FontWeight.w700,
      color: isSelected
          ? Colors.white
          : isDisabled
          ? AppColors.textMuted
          : AppColors.textPrimary,
    );
    final priceStyle = AppTextStyles.cardMeta.copyWith(
      fontSize: 10.sp,
      color: isDisabled ? AppColors.textMuted : const Color(0xFF17B26A),
    );
    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7A3EF2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$day', style: dayStyle),
            if (price != null)
              Text(
                '${currency.isEmpty ? '' : currency} ${price!.round()}',
                style: priceStyle,
              ),
          ],
        ),
      ),
    );
  }
}

String _monthLabel(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
