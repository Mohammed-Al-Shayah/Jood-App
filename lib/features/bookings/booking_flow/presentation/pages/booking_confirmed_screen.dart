import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/app_strings.dart';
import 'package:jood/core/utils/payment_amount_utils.dart';
import 'package:jood/core/utils/extensions.dart';
import '../cubit/booking_flow_cubit.dart';
import '../cubit/booking_flow_state.dart';
import '../models/booking_amounts_view_model.dart';
import '../widgets/booking_confirmed/booking_confirmed_utils.dart';
import '../widgets/booking_confirmed/booking_details_card.dart';
import '../widgets/booking_confirmed/booking_important_card.dart';
import '../widgets/booking_confirmed/booking_qr_card.dart';
import '../widgets/booking_confirmed/booking_status_badge.dart';
import '../widgets/booking_confirmed/booking_action_button.dart';
import '../widgets/date_utils.dart';

class BookingConfirmedScreen extends StatelessWidget {
  const BookingConfirmedScreen({
    super.key,
    required this.restaurantName,
    this.bookingCode,
    this.qrData,
  });

  final String restaurantName;
  final String? bookingCode;
  final String? qrData;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      BookingFlowCubit,
      BookingFlowState,
      ({
        String dateLabel,
        String timeLabel,
        String currency,
        double totalAmount,
        String guestsLabel,
        String resolvedBookingCode,
        String resolvedQrData,
      })
    >(
      selector: (state) {
        final selectedOffer = state.selectedOffer();
        final amounts = BookingAmountsViewModel.calculate(
          adultPrice: selectedOffer?.priceAdult ?? 0,
          childPrice: selectedOffer?.priceChild ?? 0,
          adultOriginalPrice: selectedOffer?.priceAdultOriginal ?? 0,
          adultCount: state.adultCount,
          childCount: state.childCount,
        );
        final resolvedBookingCode =
            bookingCode ??
            _codeFromSelection(
              selectedOffer?.id,
              state.selectedDate,
              state.adultCount,
              state.childCount,
            );
        return (
          dateLabel: formatOfferDate(state.selectedDate),
          timeLabel: selectedOffer?.startTime ?? '--',
          currency: selectedOffer?.currency ?? r'$',
          totalAmount: amounts.totalPayable,
          guestsLabel: buildGuestsLabel(state.adultCount, state.childCount),
          resolvedBookingCode: resolvedBookingCode,
          resolvedQrData: (qrData != null && qrData!.trim().isNotEmpty)
              ? qrData!
              : resolvedBookingCode,
        );
      },
      builder: (context, vm) {
        return Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: BookingActionButton(
                label: AppStrings.backToHome,
                filled: true,
                onTap: () {
                  context.pushNamedAndRemoveAll(Routes.homeScreen);
                },
              ),
            ),
          ),
          body: SafeArea(
            child: PopScope(
              canPop: false,
              onPopInvokedWithResult: (_, result) {
                context.pushNamedAndRemoveAll(Routes.homeScreen);
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 96.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 12.h),
                    const BookingStatusBadge(),
                    SizedBox(height: 12.h),
                    Text('Booking Confirmed!', style: AppTextStyles.cardTitle),
                    SizedBox(height: 12.h),
                    Text(
                      'Your booking at $restaurantName is confirmed.',
                      style: AppTextStyles.cardMeta.copyWith(fontSize: 16.sp),
                    ),
                    SizedBox(height: 18.h),
                    BookingQrCard(
                      key: ValueKey(vm.resolvedBookingCode),
                      code: vm.resolvedBookingCode,
                      qrData: vm.resolvedQrData,
                    ),
                    SizedBox(height: 16.h),
                    BookingDetailsCard(
                      restaurantName: restaurantName,
                      dateLabel: vm.dateLabel,
                      timeLabel: vm.timeLabel,
                      guestsLabel: vm.guestsLabel,
                      totalPaid: formatCurrency(vm.currency, vm.totalAmount),
                    ),
                    SizedBox(height: 14.h),
                    const BookingImportantCard(),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

String _codeFromSelection(
  String? offerId,
  DateTime date,
  int adults,
  int children,
) {
  final base = offerId ?? 'JD';
  final dateLabel =
      '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  final people = adults + children;
  final hash = base.codeUnits.fold(0, (sum, unit) => sum + unit) % 10000;
  return 'BKG$dateLabel${people.toString().padLeft(2, '0')}${hash.toString().padLeft(4, '0')}';
}
