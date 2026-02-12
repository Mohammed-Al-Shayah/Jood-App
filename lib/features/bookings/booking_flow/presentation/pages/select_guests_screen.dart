import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/app_strings.dart';
import 'package:jood/core/utils/payment_amount_utils.dart';
import '../cubit/booking_flow_cubit.dart';
import '../cubit/booking_flow_state.dart';
import '../widgets/date_utils.dart';
import '../widgets/select_date_header.dart';
import '../widgets/select_guests/section_card.dart';
import '../widgets/select_guests/summary_row.dart';
import '../widgets/select_guests/ticket_row.dart';
import 'package:jood/core/routing/app_router.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/utils/extensions.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/features/offers/domain/entities/offer_entity.dart';
import '../models/booking_amounts_view_model.dart';
import 'package:jood/core/payments/payment_verification_service.dart';

class SelectGuestsScreen extends StatefulWidget {
  const SelectGuestsScreen({super.key, required this.restaurantName});

  final String restaurantName;

  @override
  State<SelectGuestsScreen> createState() => _SelectGuestsScreenState();
}

class _SelectGuestsScreenState extends State<SelectGuestsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PaymentVerificationService.checkAndHandlePendingPayment(
        context,
        cubit: context.read<BookingFlowCubit>(),
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      PaymentVerificationService.checkAndHandlePendingPayment(
        context,
        cubit: context.read<BookingFlowCubit>(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      BookingFlowCubit,
      BookingFlowState,
      ({
        OfferEntity? selectedOffer,
        int adultCount,
        int childCount,
        DateTime selectedDate,
      })
    >(
      selector: (state) => (
        selectedOffer: state.selectedOffer(),
        adultCount: state.adultCount,
        childCount: state.childCount,
        selectedDate: state.selectedDate,
      ),
      builder: (context, vm) {
        final selectedOffer = vm.selectedOffer;
        final remainingTotal = selectedOffer == null
            ? 0
            : ((selectedOffer.capacityAdult + selectedOffer.capacityChild) -
                      (selectedOffer.bookedAdult + selectedOffer.bookedChild))
                  .clamp(0, 1000000)
                  .toInt();
        final selectedTotal = vm.adultCount + vm.childCount;
        final adultsCanAdd =
            selectedOffer != null && selectedTotal < remainingTotal;
        final childrenCanAdd =
            selectedOffer != null && selectedTotal < remainingTotal;
        final dateLabel = formatOfferDate(vm.selectedDate);
        final summaryTime = selectedOffer == null
            ? dateLabel
            : '$dateLabel - ${selectedOffer.startTime}';
        final currency = selectedOffer?.currency ?? r'$';
        final adultPrice = selectedOffer?.priceAdult ?? 0;
        final childPrice = selectedOffer?.priceChild ?? 0;
        final amounts = BookingAmountsViewModel.calculate(
          adultPrice: adultPrice,
          childPrice: childPrice,
          adultOriginalPrice: selectedOffer?.priceAdultOriginal ?? 0,
          adultCount: vm.adultCount,
          childCount: vm.childCount,
        );

        return Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: Container(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 14.r,
                  offset: Offset(0, -6.h),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedOffer == null) return;
                    if (selectedTotal > remainingTotal) {
                      showAppSnackBar(
                        context,
                        'Selected tickets are no longer available. Please adjust quantities.',
                        type: SnackBarType.error,
                      );
                      return;
                    }
                    context.pushNamed(
                      Routes.paymentScreen,
                      arguments: PaymentArgs(
                        restaurantName: widget.restaurantName,
                        cubit: context.read<BookingFlowCubit>(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    elevation: 0,
                  ),
                  child: Text(
                    AppStrings.proceedToPayment,
                    style: AppTextStyles.cta,
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                SelectDateHeader(
                  title: AppStrings.selectGuestsTitle,
                  subtitle: widget.restaurantName,
                  onBack: () => Navigator.of(context).pop(),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionCard(
                          title: AppStrings.selectNumberOfTickets,
                          child: Column(
                            children: [
                              TicketRow(
                                label: AppStrings.adults,
                                ageLabel: AppStrings.adultsAge,
                                priceLabel: formatCurrency(
                                  currency,
                                  adultPrice,
                                ),
                                count: vm.adultCount,
                                onAdd: adultsCanAdd
                                    ? () => context
                                          .read<BookingFlowCubit>()
                                          .incrementAdults()
                                    : null,
                                onRemove: vm.adultCount > 1
                                    ? () => context
                                          .read<BookingFlowCubit>()
                                          .decrementAdults()
                                    : null,
                              ),
                              Divider(
                                color: AppColors.shadowColor,
                                height: 24.h,
                              ),
                              TicketRow(
                                label: AppStrings.children,
                                ageLabel: AppStrings.childrenAge,
                                priceLabel: formatCurrency(
                                  currency,
                                  childPrice,
                                ),
                                count: vm.childCount,
                                onAdd: childrenCanAdd
                                    ? () => context
                                          .read<BookingFlowCubit>()
                                          .incrementChildren()
                                    : null,
                                onRemove: vm.childCount > 0
                                    ? () => context
                                          .read<BookingFlowCubit>()
                                          .decrementChildren()
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        SectionCard(
                          title: AppStrings.bookingSummary,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40.w,
                                    height: 40.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.12,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.restaurant,
                                      color: AppColors.primary,
                                      size: 20.sp,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.restaurantName,
                                          style: AppTextStyles.sectionTitle
                                              .copyWith(fontSize: 15.sp),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          summaryTime,
                                          style: AppTextStyles.cardMeta
                                              .copyWith(fontSize: 12.5.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              SummaryRow(
                                label: '${AppStrings.adults} x${vm.adultCount}',
                                value: formatCurrency(
                                  currency,
                                  amounts.adultTotal,
                                ),
                              ),
                              if (vm.childCount > 0) ...[
                                SizedBox(height: 6.h),
                                SummaryRow(
                                  label:
                                      '${AppStrings.children} x${vm.childCount}',
                                  value: formatCurrency(
                                    currency,
                                    amounts.childTotal,
                                  ),
                                ),
                              ],
                              SizedBox(height: 10.h),
                              Divider(color: AppColors.shadowColor),
                              // SizedBox(height: 10.h),
                              // SummaryRow(
                              //   label: AppStrings.subtotal,
                              //   value: formatCurrency(currency, subtotal),
                              // ),
                              SizedBox(height: 10.h),
                              SummaryRow(
                                label: 'Before discount',
                                value: formatCurrency(
                                  currency,
                                  amounts.originalSubtotal,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              SummaryRow(
                                label: 'Discount',
                                value: formatCurrency(
                                  currency,
                                  -amounts.discountTotal,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              SummaryRow(
                                label: 'VAT (5%)',
                                value: formatCurrency(currency, amounts.tax),
                              ),
                              SizedBox(height: 6.h),
                              SummaryRow(
                                label: AppStrings.totalPayable,
                                value: formatCurrency(
                                  currency,
                                  amounts.totalPayable,
                                ),
                                isBold: true,
                              ),
                            ],
                          ),
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
}
