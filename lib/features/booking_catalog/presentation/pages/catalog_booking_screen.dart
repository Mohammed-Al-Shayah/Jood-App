import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/service_locator.dart';
import '../../../bookings/booking_flow/presentation/pages/payment_screen.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/payment_amount_utils.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/bottom_cta_bar.dart';
import '../../../bookings/booking_flow/presentation/cubit/booking_flow_cubit.dart';
import '../../../bookings/booking_flow/presentation/cubit/booking_flow_state.dart';
import '../../../bookings/booking_flow/presentation/models/booking_amounts_view_model.dart';
import '../../../bookings/booking_flow/presentation/widgets/calendar_sheet.dart';
import '../../../bookings/booking_flow/presentation/widgets/date_strip.dart';
import '../../../bookings/booking_flow/presentation/widgets/date_utils.dart';
import '../../../bookings/booking_flow/presentation/widgets/select_date_header.dart';
import '../../../bookings/booking_flow/presentation/widgets/select_guests/section_card.dart';
import '../../../bookings/booking_flow/presentation/widgets/select_guests/summary_row.dart';
import '../../../bookings/booking_flow/presentation/widgets/select_guests/ticket_row.dart';
import '../../../offers/domain/entities/offer_entity.dart';
import '../../domain/entities/catalog_category_type.dart';
import '../../domain/entities/catalog_item_entity.dart';
import 'catalog_booking_option.dart';
import 'catalog_booking_utils.dart';

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
  static const int _absoluteGuestCap = 99;

  String? _selectedTimeSlotKey;
  String? _selectedPackageKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingFlowCubit>().setGuestCounts(adults: 1, children: 0);
    });
  }

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
          final amounts = BookingAmountsViewModel.calculate(
            adultPrice: selectedOffer?.priceAdult ?? 0,
            childPrice: selectedOffer?.priceChild ?? 0,
            adultOriginalPrice: selectedOffer?.priceAdultOriginal ?? 0,
            adultCount: state.adultCount,
            childCount: state.childCount,
          );
          final totalGuests = state.adultCount + state.childCount;
          final canProceed =
              selectedOffer != null &&
              totalGuests > 0 &&
              totalGuests <= remainingTotal(selectedOffer);

          return Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: BottomCtaBar(
              label: selectedOffer == null
                  ? 'Select an option to continue'
                  : 'Proceed to Payment ${formatCurrency(selectedOffer.currency, amounts.totalPayable)}',
              onPressed: canProceed ? () => _proceedToPayment(context) : null,
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
                          SizedBox(height: 16.h),
                          _GuestsSection(
                            state: state,
                            selectedOffer: selectedOffer,
                            maxGuests: _absoluteGuestCap,
                          ),
                          SizedBox(height: 16.h),
                          _SummarySection(
                            item: widget.item,
                            state: state,
                            selectedOffer: selectedOffer,
                            amounts: amounts,
                            selectedTimeSlotKey: _selectedTimeSlotKey,
                            selectedPackageKey: _selectedPackageKey,
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

  Future<void> _proceedToPayment(BuildContext context) async {
    final cubit = context.read<BookingFlowCubit>();
    final before = cubit.state;
    final beforeOffer = before.selectedOffer();
    final guestCount = before.adultCount + before.childCount;
    if (beforeOffer == null) {
      showAppSnackBar(
        context,
        'Please choose an available option first.',
        type: SnackBarType.error,
      );
      return;
    }
    if (guestCount == 0) {
      showAppSnackBar(
        context,
        'Please add at least one guest.',
        type: SnackBarType.error,
      );
      return;
    }

    final beforeAmounts = BookingAmountsViewModel.calculate(
      adultPrice: beforeOffer.priceAdult,
      childPrice: beforeOffer.priceChild,
      adultOriginalPrice: beforeOffer.priceAdultOriginal,
      adultCount: before.adultCount,
      childCount: before.childCount,
    );

    final stillSelected = await cubit.refreshSelectedDate();
    final after = cubit.state;
    final afterOffer = after.selectedOffer();

    if (!context.mounted) return;
    if (!stillSelected || afterOffer == null) {
      showAppSnackBar(
        context,
        'The selected option is no longer available. Please choose again.',
        type: SnackBarType.error,
      );
      return;
    }
    if ((after.adultCount + after.childCount) > remainingTotal(afterOffer)) {
      showAppSnackBar(
        context,
        'Selected guests are no longer available. Please review your quantities.',
        type: SnackBarType.error,
      );
      return;
    }

    final afterAmounts = BookingAmountsViewModel.calculate(
      adultPrice: afterOffer.priceAdult,
      childPrice: afterOffer.priceChild,
      adultOriginalPrice: afterOffer.priceAdultOriginal,
      adultCount: after.adultCount,
      childCount: after.childCount,
    );

    final priceChanged =
        beforeOffer.id != afterOffer.id ||
        beforeOffer.priceAdult != afterOffer.priceAdult ||
        beforeOffer.priceChild != afterOffer.priceChild ||
        beforeOffer.priceAdultOriginal != afterOffer.priceAdultOriginal ||
        beforeAmounts.totalPayable != afterAmounts.totalPayable;
    if (priceChanged) {
      showAppSnackBar(
        context,
        'Pricing was updated. Review the refreshed total and continue again.',
        type: SnackBarType.info,
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: PaymentScreen(restaurantName: widget.item.name),
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

class _GuestsSection extends StatelessWidget {
  const _GuestsSection({
    required this.state,
    required this.selectedOffer,
    required this.maxGuests,
  });

  final BookingFlowState state;
  final OfferEntity? selectedOffer;
  final int maxGuests;

  @override
  Widget build(BuildContext context) {
    final remaining = selectedOffer == null ? 0 : remainingTotal(selectedOffer!);
    final totalSelected = state.adultCount + state.childCount;
    final canAddMore =
        selectedOffer != null && totalSelected < remaining && totalSelected < maxGuests;
    final currency = selectedOffer?.currency ?? r'$';
    final adultPrice = selectedOffer?.priceAdult ?? 0;
    final childPrice = selectedOffer?.priceChild ?? 0;
    final cubit = context.read<BookingFlowCubit>();

    return SectionCard(
      title: 'Guests',
      child: Column(
        children: [
          TicketRow(
            label: 'Adults',
            ageLabel: '13+ years',
            priceLabel: formatCurrency(currency, adultPrice),
            count: state.adultCount,
            onAdd: canAddMore
                ? () => cubit.setAdultCount(state.adultCount + 1)
                : null,
            onRemove: state.adultCount > 0
                ? () => cubit.setAdultCount(state.adultCount - 1)
                : null,
          ),
          Divider(color: AppColors.shadowColor, height: 24.h),
          TicketRow(
            label: 'Children',
            ageLabel: '2-12 years',
            priceLabel: formatCurrency(currency, childPrice),
            count: state.childCount,
            onAdd: canAddMore
                ? () => cubit.setChildCount(state.childCount + 1)
                : null,
            onRemove: state.childCount > 0
                ? () => cubit.setChildCount(state.childCount - 1)
                : null,
          ),
          if (selectedOffer != null && remaining > 0) ...[
            SizedBox(height: 12.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$remaining spots available for this selection.',
                style: AppTextStyles.cardMeta.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({
    required this.item,
    required this.state,
    required this.selectedOffer,
    required this.amounts,
    required this.selectedTimeSlotKey,
    required this.selectedPackageKey,
  });

  final CatalogItemEntity item;
  final BookingFlowState state;
  final OfferEntity? selectedOffer;
  final BookingAmountsViewModel amounts;
  final String? selectedTimeSlotKey;
  final String? selectedPackageKey;

  @override
  Widget build(BuildContext context) {
    final currency = selectedOffer?.currency ?? r'$';
    final selectedLabel = selectionLabel(
      item: item,
      selectedOffer: selectedOffer,
      selectedTimeSlotKey: selectedTimeSlotKey,
      selectedPackageKey: selectedPackageKey,
    );

    return SectionCard(
      title: 'Booking Summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 15.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            '${formatOfferDate(state.selectedDate)}${selectedLabel.isEmpty ? '' : ' • $selectedLabel'}',
            style: AppTextStyles.cardMeta.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12.5.sp,
            ),
          ),
          SizedBox(height: 12.h),
          SummaryRow(
            label: 'Adults x${state.adultCount}',
            value: formatCurrency(currency, amounts.adultTotal),
          ),
          if (state.childCount > 0) ...[
            SizedBox(height: 6.h),
            SummaryRow(
              label: 'Children x${state.childCount}',
              value: formatCurrency(currency, amounts.childTotal),
            ),
          ],
          SizedBox(height: 10.h),
          Divider(color: AppColors.shadowColor),
          SizedBox(height: 10.h),
          SummaryRow(
            label: 'Before discount',
            value: formatCurrency(currency, amounts.originalSubtotal),
          ),
          SizedBox(height: 6.h),
          SummaryRow(
            label: 'Discount',
            value: formatCurrency(currency, -amounts.discountTotal),
          ),
          SizedBox(height: 6.h),
          SummaryRow(
            label: 'VAT (5%)',
            value: formatCurrency(currency, amounts.tax),
          ),
          SizedBox(height: 6.h),
          SummaryRow(
            label: 'Total Payable',
            value: formatCurrency(currency, amounts.totalPayable),
            isBold: true,
          ),
          if (item.requiresMenuItemSelection) ...[
            SizedBox(height: 12.h),
            Text(
              'Set menu item selection will be completed after the booking step.',
              style: AppTextStyles.cardMeta.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
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
    return SectionCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          ...options.map((option) {
            final isSelected = selectedIndex != null
                ? selectedIndex == option.offerIndex
                : selectedKey == option.key;
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
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
            );
          }),
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: option.isEnabled
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                    if (option.subtitle.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        option.subtitle,
                        style: AppTextStyles.cardMeta.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12.5.sp,
                        ),
                      ),
                    ],
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text(
                          option.primaryPriceLabel,
                          style: AppTextStyles.cardPrice.copyWith(
                            color: option.isEnabled
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                        ),
                        if (option.secondaryPriceLabel.isNotEmpty) ...[
                          SizedBox(width: 10.w),
                          Text(
                            option.secondaryPriceLabel,
                            style: AppTextStyles.cardMeta.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
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
        ),
      ),
    );
  }
}


