import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../offers/domain/entities/offer_entity.dart';
import '../cubit/booking_flow_cubit.dart';
import '../cubit/booking_flow_state.dart';
import '../widgets/date_utils.dart';
import '../widgets/select_date_header.dart';
import '../widgets/select_guests/section_card.dart';
import '../widgets/select_guests/summary_row.dart';
import '../widgets/select_guests/ticket_row.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/extensions.dart';

class SelectGuestsScreen extends StatelessWidget {
  const SelectGuestsScreen({super.key, required this.restaurantName});

  final String restaurantName;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingFlowCubit, BookingFlowState>(
      builder: (context, state) {
        final selectedOffer = _selectedOffer(state);
        final dateLabel = formatOfferDate(state.selectedDate);
        final summaryTime = selectedOffer == null
            ? dateLabel
            : '$dateLabel - ${selectedOffer.startTime}';
        final currency = selectedOffer?.currency ?? r'$';
        final adultPrice = selectedOffer?.priceAdult ?? 0;
        final childPrice = selectedOffer?.priceChild ?? 0;
        final adultTotal = adultPrice * state.adultCount;
        final childTotal = childPrice * state.childCount;
        final subtotal = adultTotal + childTotal;

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
                    context.pushNamed(
                      Routes.paymentScreen,
                      arguments: PaymentArgs(
                        restaurantName: restaurantName,
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
                  subtitle: restaurantName,
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
                                priceLabel: _formatCurrency(currency, adultPrice),
                                count: state.adultCount,
                                onAdd: () => context
                                    .read<BookingFlowCubit>()
                                    .incrementAdults(),
                                onRemove: state.adultCount > 1
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
                                priceLabel: _formatCurrency(currency, childPrice),
                                count: state.childCount,
                                onAdd: () => context
                                    .read<BookingFlowCubit>()
                                    .incrementChildren(),
                                onRemove: state.childCount > 0
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
                                          restaurantName,
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
                                  label:
                                      '${AppStrings.adults} x${state.adultCount}',
                                  value: _formatCurrency(currency, adultTotal),
                                ),
                              if (state.childCount > 0) ...[
                                SizedBox(height: 6.h),
                                SummaryRow(
                                  label:
                                      '${AppStrings.children} x${state.childCount}',
                                  value: _formatCurrency(currency, childTotal),
                                ),
                              ],
                              SizedBox(height: 10.h),
                              Divider(color: AppColors.shadowColor),
                              SizedBox(height: 10.h),
                              SummaryRow(
                                label: AppStrings.subtotal,
                                value: _formatCurrency(currency, subtotal),
                              ),
                              SizedBox(height: 6.h),
                              SummaryRow(
                                label: AppStrings.totalPayable,
                                value: _formatCurrency(currency, subtotal),
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

  OfferEntity? _selectedOffer(BookingFlowState state) {
    final index = state.selectedOfferIndex;
    if (index == null) return null;
    if (index < 0 || index >= state.offers.length) return null;
    return state.offers[index];
  }
}

String _formatCurrency(String currency, double value) {
  final rounded = value.round();
  final trimmed = currency.trim();
  if (trimmed.isEmpty) {
    return '\$$rounded';
  }
  final isSymbol = trimmed.length == 1 || RegExp(r'[$€£¥]').hasMatch(trimmed);
  return isSymbol ? '$trimmed$rounded' : '$trimmed $rounded';
}
