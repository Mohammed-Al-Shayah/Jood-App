import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/guest_pricing_utils.dart';
import '../../../../core/utils/payment_amount_utils.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/bottom_cta_bar.dart';
import '../../../bookings/booking_flow/presentation/cubit/booking_flow_cubit.dart';
import '../../../bookings/booking_flow/presentation/cubit/booking_flow_state.dart';
import '../../../bookings/booking_flow/presentation/models/booking_amounts_view_model.dart';
import '../../../bookings/booking_flow/presentation/pages/payment_screen.dart';
import '../../../bookings/booking_flow/presentation/widgets/date_utils.dart';
import '../../../bookings/booking_flow/presentation/widgets/select_date_header.dart';
import '../../../bookings/booking_flow/presentation/widgets/select_guests/section_card.dart';
import '../../../bookings/booking_flow/presentation/widgets/select_guests/summary_row.dart';
import '../../../bookings/booking_flow/presentation/widgets/select_guests/ticket_row.dart';
import '../../../offers/domain/entities/offer_entity.dart';
import '../../domain/entities/catalog_category_type.dart';
import '../../domain/entities/catalog_item_entity.dart';
import 'catalog_booking_utils.dart';

class CatalogGuestsScreen extends StatefulWidget {
  const CatalogGuestsScreen({super.key, required this.item});

  final CatalogItemEntity item;

  @override
  State<CatalogGuestsScreen> createState() => _CatalogGuestsScreenState();
}

class _CatalogGuestsScreenState extends State<CatalogGuestsScreen> {
  static const int _absoluteGuestCap = 99;

  bool _usesUnifiedGuestCount(OfferEntity? offer) {
    if (offer != null) return offer.usesUnifiedGuestCount;
    return usesUnifiedGuestCount(
      bookingCategory: widget.item.category.routeKey,
      bookableType: widget.item.category == CatalogCategoryType.attraction
          ? 'attraction'
          : 'restaurant',
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<BookingFlowCubit>();
      final selectedOffer = cubit.state.selectedOffer();
      final currentTotal = cubit.state.adultCount + cubit.state.childCount;
      if (_usesUnifiedGuestCount(selectedOffer)) {
        final nextCount = currentTotal == 0 ? 1 : currentTotal;
        if (cubit.state.adultCount != nextCount ||
            cubit.state.childCount != 0) {
          cubit.setGuestCounts(adults: nextCount, children: 0);
        }
        return;
      }
      if (currentTotal == 0) {
        cubit.setGuestCounts(adults: 1, children: 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingFlowCubit, BookingFlowState>(
      builder: (context, state) {
        final selectedOffer = state.selectedOffer();
        final usesUnifiedGuestCount = _usesUnifiedGuestCount(selectedOffer);
        final isCouponPricing = isCouponGuestPricingMode(
          guestPricingMode: selectedOffer?.guestPricingMode ?? '',
          bookingCategory: selectedOffer?.bookingCategory ?? '',
          bookableType: selectedOffer?.bookableType ?? '',
        );
        final normalizedAdultCount = usesUnifiedGuestCount
            ? state.adultCount + state.childCount
            : state.adultCount;
        final normalizedChildCount = usesUnifiedGuestCount
            ? 0
            : state.childCount;
        final amounts = BookingAmountsViewModel.calculate(
          adultPrice: selectedOffer?.priceAdult ?? 0,
          childPrice: usesUnifiedGuestCount
              ? 0
              : (selectedOffer?.priceChild ?? 0),
          adultOriginalPrice: selectedOffer?.priceAdultOriginal ?? 0,
          adultCount: normalizedAdultCount,
          childCount: normalizedChildCount,
        );
        final totalGuests = normalizedAdultCount + normalizedChildCount;
        final canProceed =
            selectedOffer != null &&
            totalGuests > 0 &&
            totalGuests <= remainingTotal(selectedOffer);

        return Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: BottomCtaBar(
            label: selectedOffer == null
                ? AppStrings.selectOptionFirst
                : AppStrings.proceedToPaymentAmount(
                    formatCurrency(
                      selectedOffer.currency,
                      amounts.totalPayable,
                    ),
                  ),
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
                  title:
                      widget.item.category == CatalogCategoryType.combo ||
                          isCouponPricing
                      ? AppStrings.selectQuantityTitle
                      : AppStrings.selectGuestsTitle,
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
                        _SelectedOptionSection(
                          item: widget.item,
                          selectedOffer: selectedOffer,
                          selectedDate: state.selectedDate,
                          usesUnifiedGuestCount: usesUnifiedGuestCount,
                        ),
                        SizedBox(height: 16.h),
                        _GuestsSection(
                          item: widget.item,
                          state: state,
                          selectedOffer: selectedOffer,
                          maxGuests: _absoluteGuestCap,
                          usesUnifiedGuestCount: usesUnifiedGuestCount,
                        ),
                        SizedBox(height: 16.h),
                        _SummarySection(
                          item: widget.item,
                          selectedOffer: selectedOffer,
                          amounts: amounts,
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
        AppStrings.pleaseChooseAvailableOptionFirst,
        type: SnackBarType.error,
      );
      return;
    }
    if (guestCount == 0) {
      showAppSnackBar(
        context,
        widget.item.category == CatalogCategoryType.combo
            ? AppStrings.pleaseAddAtLeastOneCombo
            : AppStrings.pleaseAddAtLeastOneGuest,
        type: SnackBarType.error,
      );
      return;
    }

    final usesUnifiedGuestCount = _usesUnifiedGuestCount(beforeOffer);
    final beforeAmounts = BookingAmountsViewModel.calculate(
      adultPrice: beforeOffer.priceAdult,
      childPrice: usesUnifiedGuestCount ? 0 : beforeOffer.priceChild,
      adultOriginalPrice: beforeOffer.priceAdultOriginal,
      adultCount: usesUnifiedGuestCount ? guestCount : before.adultCount,
      childCount: usesUnifiedGuestCount ? 0 : before.childCount,
    );

    final stillSelected = await cubit.refreshSelectedDate();
    final after = cubit.state;
    final afterOffer = after.selectedOffer();

    if (!context.mounted) return;
    if (!stillSelected || afterOffer == null) {
      showAppSnackBar(
        context,
        AppStrings.selectedOptionNoLongerAvailable,
        type: SnackBarType.error,
      );
      return;
    }
    if ((after.adultCount + after.childCount) > remainingTotal(afterOffer)) {
      showAppSnackBar(
        context,
        AppStrings.selectedGuestsNoLongerAvailable,
        type: SnackBarType.error,
      );
      return;
    }

    final afterUsesUnifiedGuestCount = _usesUnifiedGuestCount(afterOffer);
    final afterGuestCount = after.adultCount + after.childCount;
    final afterAmounts = BookingAmountsViewModel.calculate(
      adultPrice: afterOffer.priceAdult,
      childPrice: afterUsesUnifiedGuestCount ? 0 : afterOffer.priceChild,
      adultOriginalPrice: afterOffer.priceAdultOriginal,
      adultCount: afterUsesUnifiedGuestCount
          ? afterGuestCount
          : after.adultCount,
      childCount: afterUsesUnifiedGuestCount ? 0 : after.childCount,
    );

    final priceChanged =
        beforeOffer.id != afterOffer.id ||
        beforeOffer.priceAdult != afterOffer.priceAdult ||
        (!usesUnifiedGuestCount &&
            beforeOffer.priceChild != afterOffer.priceChild) ||
        beforeOffer.priceAdultOriginal != afterOffer.priceAdultOriginal ||
        beforeAmounts.totalPayable != afterAmounts.totalPayable;
    if (priceChanged) {
      showAppSnackBar(
        context,
        AppStrings.pricingWasUpdated,
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

class _SelectedOptionSection extends StatelessWidget {
  const _SelectedOptionSection({
    required this.item,
    required this.selectedOffer,
    required this.selectedDate,
    required this.usesUnifiedGuestCount,
  });

  final CatalogItemEntity item;
  final OfferEntity? selectedOffer;
  final DateTime selectedDate;
  final bool usesUnifiedGuestCount;

  @override
  Widget build(BuildContext context) {
    final isCouponPricing = isCouponGuestPricingMode(
      guestPricingMode: selectedOffer?.guestPricingMode ?? '',
      bookingCategory: selectedOffer?.bookingCategory ?? '',
      bookableType: selectedOffer?.bookableType ?? '',
    );
    final selectedLabel = selectionLabel(
      item: item,
      selectedOffer: selectedOffer,
      selectedTimeSlotKey: null,
      selectedPackageKey: null,
    );

    return SectionCard(
      title: AppStrings.selectedOption,
      child: selectedOffer == null
          ? Text(
              AppStrings.goBackAndChooseAvailableOptionFirst,
              style: AppTextStyles.cardMeta.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 15.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${formatOfferDate(selectedDate)}${selectedLabel.isEmpty ? '' : ' | $selectedLabel'}',
                  style: AppTextStyles.cardMeta.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12.5.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Text(
                      formatCurrency(
                        selectedOffer!.currency,
                        selectedOffer!.priceAdult,
                      ),
                      style: AppTextStyles.cardPrice.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    if (usesUnifiedGuestCount) ...[
                      SizedBox(width: 10.w),
                      Text(
                        item.category == CatalogCategoryType.combo
                            ? AppStrings.perCombo
                            : isCouponPricing
                            ? AppStrings.perCoupon
                            : AppStrings.perPerson,
                        style: AppTextStyles.cardMeta.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ] else ...[
                      SizedBox(width: 10.w),
                      Text(
                        AppStrings.childPrice(
                          formatCurrency(
                            selectedOffer!.currency,
                            selectedOffer!.priceChild,
                          ),
                        ),
                        style: AppTextStyles.cardMeta.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
    );
  }
}

class _GuestsSection extends StatelessWidget {
  const _GuestsSection({
    required this.item,
    required this.state,
    required this.selectedOffer,
    required this.maxGuests,
    required this.usesUnifiedGuestCount,
  });

  final CatalogItemEntity item;
  final BookingFlowState state;
  final OfferEntity? selectedOffer;
  final int maxGuests;
  final bool usesUnifiedGuestCount;

  @override
  Widget build(BuildContext context) {
    final remaining = selectedOffer == null
        ? 0
        : remainingTotal(selectedOffer!);
    final unifiedCount = state.adultCount + state.childCount;
    final totalSelected = usesUnifiedGuestCount
        ? unifiedCount
        : state.adultCount + state.childCount;
    final canAddMore =
        selectedOffer != null &&
        totalSelected < remaining &&
        totalSelected < maxGuests;
    final currency = selectedOffer?.currency ?? r'$';
    final adultPrice = selectedOffer?.priceAdult ?? 0;
    final childPrice = selectedOffer?.priceChild ?? 0;
    final cubit = context.read<BookingFlowCubit>();
    final isCombo = item.category == CatalogCategoryType.combo;
    final isCouponPricing = isCouponGuestPricingMode(
      guestPricingMode: selectedOffer?.guestPricingMode ?? '',
      bookingCategory: selectedOffer?.bookingCategory ?? '',
      bookableType: selectedOffer?.bookableType ?? '',
    );

    return SectionCard(
      title: selectionCountTitle(
        bookingCategory: item.category.routeKey,
        guestPricingMode: selectedOffer?.guestPricingMode ?? '',
        bookableType: selectedOffer?.bookableType ?? 'restaurant',
      ),
      child: Column(
        children: [
          if (usesUnifiedGuestCount) ...[
            TicketRow(
              label: isCombo
                  ? AppStrings.combos
                  : isCouponPricing
                  ? AppStrings.coupons
                  : AppStrings.guests,
              ageLabel: isCombo
                  ? AppStrings.samePriceForAllCombos
                  : isCouponPricing
                  ? AppStrings.samePriceForAllCoupons
                  : AppStrings.samePriceForAllGuests,
              priceLabel:
                  '${formatCurrency(currency, adultPrice)} ${isCombo
                      ? AppStrings.perCombo
                      : isCouponPricing
                      ? AppStrings.perCoupon
                      : AppStrings.perPerson}',
              count: unifiedCount,
              onAdd: canAddMore
                  ? () => cubit.setGuestCounts(
                      adults: unifiedCount + 1,
                      children: 0,
                    )
                  : null,
              onRemove: unifiedCount > 0
                  ? () => cubit.setGuestCounts(
                      adults: unifiedCount - 1,
                      children: 0,
                    )
                  : null,
            ),
          ] else ...[
            TicketRow(
              label: AppStrings.adults,
              ageLabel: AppStrings.adultsAge,
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
              label: AppStrings.children,
              ageLabel: AppStrings.childrenAge,
              priceLabel: formatCurrency(currency, childPrice),
              count: state.childCount,
              onAdd: canAddMore
                  ? () => cubit.setChildCount(state.childCount + 1)
                  : null,
              onRemove: state.childCount > 0
                  ? () => cubit.setChildCount(state.childCount - 1)
                  : null,
            ),
          ],
          if (selectedOffer != null && remaining > 0) ...[
            SizedBox(height: 12.h),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                isCombo
                    ? AppStrings.combosAvailableForSelection(remaining)
                    : isCouponPricing
                    ? AppStrings.couponsAvailableForSelection(remaining)
                    : AppStrings.spotsAvailableForSelection(remaining),
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
    required this.selectedOffer,
    required this.amounts,
  });

  final CatalogItemEntity item;
  final OfferEntity? selectedOffer;
  final BookingAmountsViewModel amounts;

  @override
  Widget build(BuildContext context) {
    final currency = selectedOffer?.currency ?? r'$';

    return SectionCard(
      title: AppStrings.bookingSummary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SummaryRow(
            label: AppStrings.beforeDiscount,
            value: formatCurrency(currency, amounts.originalSubtotal),
          ),
          SizedBox(height: 6.h),
          SummaryRow(
            label: AppStrings.discount,
            value: formatCurrency(currency, -amounts.discountTotal),
          ),
          SizedBox(height: 6.h),
          SummaryRow(
            label: AppStrings.vatWithRate('5%'),
            value: formatCurrency(currency, amounts.tax),
          ),
          SizedBox(height: 6.h),
          SummaryRow(
            label: AppStrings.totalPayable,
            value: formatCurrency(currency, amounts.totalPayable),
            isBold: true,
          ),
          if (item.requiresMenuItemSelection) ...[
            SizedBox(height: 12.h),
            Text(
              AppStrings.setMenuItemSelectionAfterBooking,
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
