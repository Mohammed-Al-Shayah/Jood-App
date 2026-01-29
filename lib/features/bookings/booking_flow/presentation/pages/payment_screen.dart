import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/app_strings.dart';
import 'package:jood/core/routing/app_router.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/utils/extensions.dart';
import 'package:jood/features/offers/domain/entities/offer_entity.dart';
import '../cubit/booking_flow_cubit.dart';
import '../cubit/booking_flow_state.dart';
import '../widgets/date_utils.dart';
import '../widgets/payment/payment_input_field.dart';
import '../widgets/payment/payment_secure_card.dart';
import '../widgets/payment/payment_summary_card.dart';
import '../widgets/select_date_header.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key, required this.restaurantName});

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
        final totalAmount = adultTotal + childTotal;

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
                      Routes.bookingConfirmedScreen,
                      arguments: BookingConfirmedArgs(
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
                    '${AppStrings.confirmAndPay} ${_formatCurrency(currency, totalAmount)}',
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
                  title: AppStrings.paymentTitle,
                  subtitle: AppStrings.paymentSubtitle,
                  onBack: () => Navigator.of(context).pop(),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PaymentSummaryCard(
                          restaurantName: restaurantName,
                          timeLabel: summaryTime,
                          totalAmount: _formatCurrency(currency, totalAmount),
                          adultsCount: state.adultCount,
                          childrenCount: state.childCount,
                        ),
                        SizedBox(height: 18.h),
                        Text(
                          AppStrings.cardholderName,
                          style: AppTextStyles.sectionTitle.copyWith(
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        PaymentInputField(
                          hintText: 'John Doe',
                          keyboardType: TextInputType.name,
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          AppStrings.cardNumber,
                          style: AppTextStyles.sectionTitle.copyWith(
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        PaymentInputField(
                          hintText: '1234 5678 9012 3456',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 14.h),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.expiryDate,
                                    style: AppTextStyles.sectionTitle.copyWith(
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  PaymentInputField(
                                    hintText: 'MM/YY',
                                    keyboardType: TextInputType.datetime,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.cvv,
                                    style: AppTextStyles.sectionTitle.copyWith(
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  PaymentInputField(
                                    hintText: '123',
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        const PaymentSecureCard(),
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


