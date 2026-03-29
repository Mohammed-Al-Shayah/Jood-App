import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/bottom_cta_bar.dart';
import '../../../bookings/booking_flow/presentation/cubit/booking_flow_cubit.dart';
import '../../../bookings/booking_flow/presentation/cubit/booking_flow_state.dart';
import '../../../bookings/booking_flow/presentation/widgets/calendar_sheet.dart';
import '../../../bookings/booking_flow/presentation/widgets/date_strip.dart';
import '../../../bookings/booking_flow/presentation/widgets/select_date_header.dart';
import '../../domain/entities/catalog_category_type.dart';
import '../../domain/entities/catalog_item_entity.dart';
import 'catalog_booking_option.dart';
import 'catalog_booking_utils.dart';
import 'catalog_guests_screen.dart';

class CatalogBookingScreen extends StatelessWidget {
  const CatalogBookingScreen({super.key, required this.item});

  final CatalogItemEntity item;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookingFlowCubit>()
        ..initialize(
          restaurantId: item.id,
          bookingCategory: item.category.routeKey,
        ),
      child: _CatalogBookingView(item: item),
    );
  }
}

class _CatalogBookingView extends StatefulWidget {
  const _CatalogBookingView({required this.item});

  final CatalogItemEntity item;

  @override
  State<_CatalogBookingView> createState() => _CatalogBookingViewState();
}

class _CatalogBookingViewState extends State<_CatalogBookingView> {
  String? _selectedTimeSlotKey;
  String? _selectedPackageKey;

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingFlowCubit, BookingFlowState>(
      listenWhen: (previous, current) =>
          previous.offers != current.offers ||
          previous.selectedDate != current.selectedDate,
      listener: (context, state) {
        if (widget.item.bookingMode == CatalogBookingMode.timeSlotBased) {
          _syncAttractionSelection(state);
        }
      },
      child: BlocBuilder<BookingFlowCubit, BookingFlowState>(
        builder: (context, state) {
          final selectedOffer = state.selectedOffer();
          final canProceed = selectedOffer != null;

          return Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: BottomCtaBar(
              label: selectedOffer == null ? 'Select an option to continue' : 'Next',
              onPressed: canProceed ? () => _goToGuests(context) : null,
              backgroundColor: Colors.white,
              shadowColor: AppColors.shadowColor,
              textStyle: AppTextStyles.cta,
              buttonColor: AppColors.primary,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  SelectDateHeader(
                    title: headerTitle(widget.item.category),
                    subtitle: widget.item.name,
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(height: 12.h),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 86.h,
                            child: DateStrip(
                              dates: state.dates,
                              selectedIndex: state.selectedDateIndex,
                              onDateTap: (index) => context
                                  .read<BookingFlowCubit>()
                                  .selectDate(index),
                              onMoreTap: () => _openDatePicker(context),
                              datePrices: state.datePrices,
                              currency: state.currency,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          if (state.status == BookingFlowStatus.loading)
                            const LinearProgressIndicator(
                              color: AppColors.primary,
                            ),
                          if (state.status == BookingFlowStatus.failure)
                            Padding(
                              padding: EdgeInsets.only(top: 16.h),
                              child: Text(
                                state.errorMessage ??
                                    'Failed to load booking options.',
                                style: AppTextStyles.cardMeta,
                              ),
                            ),
                          if (widget.item.bookingMode ==
                              CatalogBookingMode.mealBased)
                            _MealBasedSection(item: widget.item, state: state)
                          else
                            _AttractionSection(
                              state: state,
                              selectedTimeSlotKey: _selectedTimeSlotKey,
                              selectedPackageKey: _selectedPackageKey,
                              onTimeSlotSelected: _handleTimeSlotSelected,
                              onPackageSelected: _handlePackageSelected,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _syncAttractionSelection(BookingFlowState state) {
    final slotOptions = buildTimeSlotOptions(state.offers);
    if (slotOptions.isEmpty) {
      if (_selectedTimeSlotKey != null || _selectedPackageKey != null) {
        setState(() {
          _selectedTimeSlotKey = null;
          _selectedPackageKey = null;
        });
      }
      context.read<BookingFlowCubit>().clearSelectedOffer();
      return;
    }

    final currentSlotExists = slotOptions.any(
      (slot) => slot.key == _selectedTimeSlotKey && slot.isEnabled,
    );
    final nextSlot = currentSlotExists
        ? _selectedTimeSlotKey
        : firstWhereOrNull(slotOptions, (slot) => slot.isEnabled)?.key;

    if (nextSlot == null) {
      setState(() {
        _selectedTimeSlotKey = null;
        _selectedPackageKey = null;
      });
      context.read<BookingFlowCubit>().clearSelectedOffer();
      return;
    }

    final packageOptions = buildPackageOptions(
      state.offers,
      timeSlot: nextSlot,
    );
    final currentPackageExists = packageOptions.any(
      (package) => package.key == _selectedPackageKey && package.isEnabled,
    );
    final nextPackage = currentPackageExists
        ? _selectedPackageKey
        : firstWhereOrNull(packageOptions, (package) => package.isEnabled)?.key;

    int? selectedIndex;
    if (nextPackage != null) {
      final selectedPackage = packageOptions.firstWhere(
        (package) => package.key == nextPackage,
      );
      selectedIndex = selectedPackage.offerIndex;
    }

    final cubit = context.read<BookingFlowCubit>();
    final currentIndex = state.selectedOfferIndex;
    if (nextSlot != _selectedTimeSlotKey || nextPackage != _selectedPackageKey) {
      setState(() {
        _selectedTimeSlotKey = nextSlot;
        _selectedPackageKey = nextPackage;
      });
    }
    if (currentIndex != selectedIndex) {
      cubit.selectOfferIndex(selectedIndex);
    }
  }

  void _handleTimeSlotSelected(String key) {
    final cubit = context.read<BookingFlowCubit>();
    final packageOptions = buildPackageOptions(cubit.state.offers, timeSlot: key);
    final selectedPackage = firstWhereOrNull(
      packageOptions,
      (package) => package.isEnabled,
    );
    setState(() {
      _selectedTimeSlotKey = key;
      _selectedPackageKey = selectedPackage?.key;
    });
    cubit.selectOfferIndex(selectedPackage?.offerIndex);
  }

  void _handlePackageSelected(String key) {
    final timeSlotKey = _selectedTimeSlotKey;
    if (timeSlotKey == null) return;
    final packageOptions = buildPackageOptions(
      context.read<BookingFlowCubit>().state.offers,
      timeSlot: timeSlotKey,
    );
    final selectedPackage = packageOptions.firstWhere(
      (package) => package.key == key,
    );
    setState(() => _selectedPackageKey = key);
    context.read<BookingFlowCubit>().selectOfferIndex(selectedPackage.offerIndex);
  }

  Future<void> _openDatePicker(BuildContext context) async {
    final cubit = context.read<BookingFlowCubit>();
    final now = DateTime.now();

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => CalendarSheet(
        initialMonth: DateTime(now.year, now.month, 1),
        selectedDate: cubit.state.selectedDate,
        monthCount: 12,
        currency: cubit.state.currency.isEmpty ? 'AED' : cubit.state.currency,
        pricesLoader: (month) => cubit.loadDiscountPricesForMonth(month),
      ),
    );

    if (picked == null) return;
    await cubit.selectCustomDate(
      DateTime(picked.year, picked.month, picked.day),
    );
  }

  void _goToGuests(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<BookingFlowCubit>(),
          child: CatalogGuestsScreen(item: widget.item),
        ),
      ),
    );
  }
}

class _MealBasedSection extends StatelessWidget {
  const _MealBasedSection({required this.item, required this.state});

  final CatalogItemEntity item;
  final BookingFlowState state;

  @override
  Widget build(BuildContext context) {
    final options = buildMealOptions(item, state.offers);
    if (state.status == BookingFlowStatus.ready && options.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 20.h),
        child: Text(
          item.category == CatalogCategoryType.setMenu
              ? 'No set menu options are available for this date.'
              : 'No meals are available for this date.',
          style: AppTextStyles.cardMeta.copyWith(
            fontSize: 13.sp,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return _OptionsSection(
      title: item.category == CatalogCategoryType.setMenu
          ? 'Choose Set Menu'
          : 'Choose Meal Type',
      subtitle: item.category == CatalogCategoryType.setMenu
          ? 'Each set menu option can carry its own adult and child pricing.'
          : 'Select the meal that should be booked for the chosen date.',
      options: options,
      selectedIndex: state.selectedOfferIndex,
      onSelected: (index) =>
          context.read<BookingFlowCubit>().selectOfferIndex(index),
    );
  }
}

class _AttractionSection extends StatelessWidget {
  const _AttractionSection({
    required this.state,
    required this.selectedTimeSlotKey,
    required this.selectedPackageKey,
    required this.onTimeSlotSelected,
    required this.onPackageSelected,
  });

  final BookingFlowState state;
  final String? selectedTimeSlotKey;
  final String? selectedPackageKey;
  final ValueChanged<String> onTimeSlotSelected;
  final ValueChanged<String> onPackageSelected;

  @override
  Widget build(BuildContext context) {
    final timeSlots = buildTimeSlotOptions(state.offers);
    final packageOptions = selectedTimeSlotKey == null
        ? const <CatalogBookingOption>[]
        : buildPackageOptions(state.offers, timeSlot: selectedTimeSlotKey!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.status == BookingFlowStatus.ready && timeSlots.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 20.h),
            child: Text(
              'No time slots are available for this date.',
              style: AppTextStyles.cardMeta.copyWith(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
            ),
          )
        else ...[
          _OptionsSection(
            title: 'Select Time',
            subtitle:
                'Different time slots can carry different pricing and package availability.',
            options: timeSlots,
            selectedKey: selectedTimeSlotKey,
            onSelectedKey: onTimeSlotSelected,
          ),
          SizedBox(height: 16.h),
          _OptionsSection(
            title: 'Select Package',
            subtitle:
                'Only packages available for the selected time slot are shown.',
            options: packageOptions,
            selectedKey: selectedPackageKey,
            onSelectedKey: onPackageSelected,
          ),
        ],
      ],
    );
  }
}

class _OptionsSection extends StatelessWidget {
  const _OptionsSection({
    required this.title,
    required this.subtitle,
    required this.options,
    this.selectedIndex,
    this.selectedKey,
    this.onSelected,
    this.onSelectedKey,
  });

  final String title;
  final String subtitle;
  final List<CatalogBookingOption> options;
  final int? selectedIndex;
  final String? selectedKey;
  final ValueChanged<int>? onSelected;
  final ValueChanged<String>? onSelectedKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sectionTitle),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: AppTextStyles.cardMeta.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12.5.sp,
            ),
          ),
          SizedBox(height: 14.h),
          if (options.isEmpty)
            Text(
              'No options available right now.',
              style: AppTextStyles.cardMeta.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          if (options.isNotEmpty)
            Builder(
              builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;
                final cardWidth = (screenWidth * 0.78).clamp(250.0, 320.0);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: options.map((option) {
                      final isSelected = selectedIndex != null
                          ? selectedIndex == option.offerIndex
                          : selectedKey == option.key;
                      return Padding(
                        padding: EdgeInsets.only(right: 12.w),
                        child: SizedBox(
                          width: cardWidth,
                          child: _OptionCard(
                            option: option,
                            isSelected: isSelected,
                            onTap: option.isEnabled
                                ? () {
                                    if (onSelected != null) {
                                      onSelected!(option.offerIndex);
                                    } else if (onSelectedKey != null) {
                                      onSelectedKey!(option.key);
                                    }
                                  }
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final CatalogBookingOption option;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? AppColors.primary : AppColors.shadowColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: option.isEnabled
                ? Colors.white
                : AppColors.iconStroke.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      option.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: option.isEnabled
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: option.isEnabled
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      option.statusLabel,
                      style: AppTextStyles.cardMeta.copyWith(
                        color: option.isEnabled
                            ? AppColors.primaryDark
                            : const Color(0xFFDD5A5A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (option.subtitle.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  option.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardMeta.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12.5.sp,
                  ),
                ),
              ],
              SizedBox(height: 10.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 4.h,
                children: [
                  Text(
                    option.primaryPriceLabel,
                    style: AppTextStyles.cardPrice.copyWith(
                      color: option.isEnabled
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ),
                  if (option.secondaryPriceLabel.isNotEmpty)
                    Text(
                      option.secondaryPriceLabel,
                      style: AppTextStyles.cardMeta.copyWith(
                        color: AppColors.textSecondary,
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
