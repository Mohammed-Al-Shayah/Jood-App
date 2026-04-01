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
              label: selectedOffer == null
                  ? 'Select an option to continue'
                  : 'Next',
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
    if (nextSlot != _selectedTimeSlotKey ||
        nextPackage != _selectedPackageKey) {
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
    final packageOptions = buildPackageOptions(
      cubit.state.offers,
      timeSlot: key,
    );
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
    context.read<BookingFlowCubit>().selectOfferIndex(
      selectedPackage.offerIndex,
    );
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
            compactCards: true,
          ),
          SizedBox(height: 16.h),
          _OptionsSection(
            title: 'Select Package',
            subtitle:
                'Only packages available for the selected time slot are shown.',
            options: packageOptions,
            selectedKey: selectedPackageKey,
            onSelectedKey: onPackageSelected,
            expandSubtitle: true,
            compactCards: true,
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
    this.expandSubtitle = false,
    this.compactCards = false,
  });

  final String title;
  final String subtitle;
  final List<CatalogBookingOption> options;
  final int? selectedIndex;
  final String? selectedKey;
  final ValueChanged<int>? onSelected;
  final ValueChanged<String>? onSelectedKey;
  final bool expandSubtitle;
  final bool compactCards;

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
            compactCards
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final cardSpacing = 10.w;
                      final cardWidth =
                          (constraints.maxWidth - (cardSpacing * 2)) / 3;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(options.length, (index) {
                            final option = options[index];
                            final isSelected = selectedIndex != null
                                ? selectedIndex == option.offerIndex
                                : selectedKey == option.key;
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index == options.length - 1
                                    ? 0
                                    : cardSpacing,
                              ),
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
                                  expandSubtitle: expandSubtitle,
                                  compactLayout: true,
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  )
                : Column(
                    children: List.generate(options.length, (index) {
                      final option = options[index];
                      final isSelected = selectedIndex != null
                          ? selectedIndex == option.offerIndex
                          : selectedKey == option.key;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == options.length - 1 ? 0 : 12.h,
                        ),
                        child: SizedBox(
                          width: double.infinity,
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
                            expandSubtitle: expandSubtitle,
                          ),
                        ),
                      );
                    }),
                  ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatefulWidget {
  const _OptionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
    this.expandSubtitle = false,
    this.compactLayout = false,
  });

  final CatalogBookingOption option;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool expandSubtitle;
  final bool compactLayout;

  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard> {
  bool _detailsVisible = false;

  void _toggleDetails() {
    setState(() => _detailsVisible = !_detailsVisible);
  }

  @override
  Widget build(BuildContext context) {
    final option = widget.option;
    final borderColor = widget.isSelected
        ? AppColors.primary
        : AppColors.shadowColor;
    final accentColor = option.isEnabled
        ? AppColors.primaryDark
        : const Color(0xFFDD5A5A);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(widget.compactLayout ? 10.r : 14.r),
          decoration: BoxDecoration(
            color: option.isEnabled
                ? Colors.white
                : AppColors.iconStroke.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: borderColor),
          ),
          child: widget.compactLayout
              ? _buildCompactBody(option, accentColor)
              : _buildDefaultBody(option, accentColor),
        ),
      ),
    );
  }

  Widget _buildCompactBody(CatalogBookingOption option, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          option.label,
          style: AppTextStyles.sectionTitle.copyWith(
            fontSize: 12.5.sp,
            height: 1.25,
            color: option.isEnabled
                ? AppColors.textPrimary
                : AppColors.textMuted,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            option.statusLabel,
            textAlign: TextAlign.center,
            style: AppTextStyles.cardMeta.copyWith(
              fontSize: 10.5.sp,
              color: accentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (option.subtitle.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            option.subtitle,
            style: AppTextStyles.cardMeta.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11.5.sp,
              height: 1.4,
            ),
          ),
        ],
        SizedBox(height: 10.h),
        Text(
          option.primaryPriceLabel,
          style: AppTextStyles.cardPrice.copyWith(
            fontSize: 12.sp,
            color: option.isEnabled ? AppColors.primary : AppColors.textMuted,
          ),
        ),
        if (option.secondaryPriceLabel.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            option.secondaryPriceLabel,
            style: AppTextStyles.cardMeta.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10.5.sp,
              height: 1.35,
            ),
          ),
        ],
        if (option.hasDetails) ...[
          SizedBox(height: 8.h),
          _buildDetailsToggle(compact: true),
          _buildDetailsPanel(compact: true),
        ],
      ],
    );
  }

  Widget _buildDefaultBody(CatalogBookingOption option, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                option.label,
                maxLines: widget.expandSubtitle ? 2 : 1,
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
        if (option.subtitle.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            option.subtitle,
            maxLines: widget.expandSubtitle ? null : 2,
            overflow: widget.expandSubtitle ? null : TextOverflow.ellipsis,
            style: AppTextStyles.cardMeta.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12.5.sp,
              height: widget.expandSubtitle ? 1.45 : null,
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
        if (option.hasDetails) ...[
          SizedBox(height: 8.h),
          _buildDetailsToggle(compact: false),
          _buildDetailsPanel(compact: false),
        ],
      ],
    );
  }

  Widget _buildDetailsToggle({required bool compact}) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleDetails,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _detailsVisible ? 'Hide details' : 'Show details',
              style: AppTextStyles.cardMeta.copyWith(
                color: AppColors.primaryDark,
                fontSize: compact ? 10.5.sp : 11.5.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              _detailsVisible
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: compact ? 18.r : 20.r,
              color: AppColors.primaryDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsPanel({required bool compact}) {
    return AnimatedCrossFade(
      firstChild: const SizedBox.shrink(),
      secondChild: Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 8.r : 10.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(widget.option.details.length, (index) {
              final detail = widget.option.details[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == widget.option.details.length - 1 ? 0 : 6.h,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 5.r,
                      height: 5.r,
                      margin: EdgeInsets.only(
                        top: compact ? 5.h : 6.h,
                        right: 8.w,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        detail,
                        style: AppTextStyles.cardMeta.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: compact ? 10.5.sp : 11.5.sp,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
      crossFadeState: _detailsVisible
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 180),
      sizeCurve: Curves.easeInOut,
    );
  }
}
