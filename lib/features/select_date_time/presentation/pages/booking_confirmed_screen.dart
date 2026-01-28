import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/extensions.dart';
import '../../../offers/domain/entities/offer_entity.dart';
import '../cubit/booking_flow_cubit.dart';
import '../cubit/booking_flow_state.dart';
import '../widgets/booking_confirmed/booking_confirmed_utils.dart';
import '../widgets/booking_confirmed/booking_details_card.dart';
import '../widgets/booking_confirmed/booking_important_card.dart';
import '../widgets/booking_confirmed/booking_qr_card.dart';
import '../widgets/booking_confirmed/booking_status_badge.dart';
import '../widgets/booking_confirmed/booking_action_button.dart';
import '../widgets/date_utils.dart';

class BookingConfirmedScreen extends StatelessWidget {
  const BookingConfirmedScreen({super.key, required this.restaurantName});

  final String restaurantName;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingFlowCubit, BookingFlowState>(
      builder: (context, state) {
        final selectedOffer = _selectedOffer(state);
        final dateLabel = formatOfferDate(state.selectedDate);
        final timeLabel = selectedOffer?.startTime ?? '--';
        final currency = selectedOffer?.currency ?? r'$';
        final adultPrice = selectedOffer?.priceAdult ?? 0;
        final childPrice = selectedOffer?.priceChild ?? 0;
        final adultTotal = adultPrice * state.adultCount;
        final childTotal = childPrice * state.childCount;
        final totalAmount = adultTotal + childTotal;
        final guestsLabel = buildGuestsLabel(
          state.adultCount,
          state.childCount,
        );
        final bookingCode = _codeFromSelection(
          selectedOffer?.id,
          state.selectedDate,
          state.adultCount,
          state.childCount,
        );

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
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
                    key: ValueKey(bookingCode),
                    code: bookingCode,
                  ),
                  SizedBox(height: 16.h),
                  BookingDetailsCard(
                    restaurantName: restaurantName,
                    dateLabel: dateLabel,
                    timeLabel: timeLabel,
                    guestsLabel: guestsLabel,
                    totalPaid: _formatCurrency(currency, totalAmount),
                  ),
                  SizedBox(height: 14.h),
                  const BookingImportantCard(),
                  SizedBox(height: 16.h),
                  BookingActionButton(
                    label: AppStrings.backToHome,
                    icon: Icons.location_on_outlined,
                    filled: true,
                    onTap: () {
                      context.pushNamed(Routes.homeScreen);
                    },
                  ),
                
                ],
              ),
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
  final isSymbol = trimmed.length == 1;
  return isSymbol ? '$trimmed$rounded' : '$trimmed $rounded';
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
