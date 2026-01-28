import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../offers/domain/entities/offer_entity.dart';
import '../cubit/booking_flow_cubit.dart';
import '../cubit/booking_flow_state.dart';
import '../widgets/date_strip.dart';
import '../widgets/date_utils.dart';
import '../widgets/offer_card.dart';
import '../widgets/select_date_header.dart';

class SelectDateTimeScreen extends StatelessWidget {
  const SelectDateTimeScreen({
    super.key,
    required this.name,
    required this.restaurantId,
  });

  final String name;
  final String restaurantId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<BookingFlowCubit>()..initialize(restaurantId: restaurantId),
      child: BlocBuilder<BookingFlowCubit, BookingFlowState>(
        builder: (context, state) {
          final selectedLabel = formatOfferDate(state.selectedDate);
          final selectedIndex = state.selectedOfferIndex;

          return Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: selectedIndex == null
                ? null
                : Container(
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
                              Routes.selectGuestsScreen,
                              arguments: SelectGuestsArgs(
                                restaurantName: name,
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
                          child: Text('Next', style: AppTextStyles.cta),
                        ),
                      ),
                    ),
                  ),
            body: SafeArea(
              child: Column(
                children: [
                  SelectDateHeader(
                    title: AppStrings.selectDateTitle,
                    subtitle: name,
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
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            '${AppStrings.availableOffersFor} $selectedLabel',
                            style: AppTextStyles.sectionTitle.copyWith(
                              fontSize: 18.sp,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          if (state.status == BookingFlowStatus.loading)
                            const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          if (state.status == BookingFlowStatus.failure)
                            Text(
                              state.errorMessage ?? 'Failed to load offers.',
                              style: AppTextStyles.cardMeta,
                            ),
                          if (state.status == BookingFlowStatus.ready &&
                              state.offers.isEmpty )
                            Column(
                              children: [
                                SizedBox(height: 200.h,),
                                  Center(
                              child: Text(
                                'No offers available for this date.',
                                style: AppTextStyles.cardMeta.copyWith(
                                  fontSize: 16.sp,color: AppColors.textPrimary),
                              ),
                            ),
                              ],
                            ),
                          
                          ...state.offers.asMap().entries.map((entry) {
                            final index = entry.key;
                            final offer = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: OfferCard(
                                offer: offer,
                                isSelected: selectedIndex == index,
                                statusLabel: _statusLabel(offer),
                                statusColor: _statusColor(offer),
                                onTap: _isSoldOut(offer)
                                    ? null
                                    : () => context
                                          .read<BookingFlowCubit>()
                                          .toggleOffer(index),
                              ),
                            );
                          }),
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

  Future<void> _openDatePicker(BuildContext context) async {
    final cubit = context.read<BookingFlowCubit>();
    final picked = await showDatePicker(
      context: context,
      initialDate: cubit.state.selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: AppTextStyles.cardMeta.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked == null) return;
    await cubit.selectCustomDate(
      DateTime(picked.year, picked.month, picked.day),
    );
  }
}

String _statusLabel(OfferEntity offer) {
  final remaining = _remainingTotal(offer);
  final availability = _availabilityFor(offer);
  switch (availability) {
    case _OfferAvailability.available:
      return '$remaining ${AppStrings.ticketsAvailable}';
    case _OfferAvailability.low:
      return '${AppStrings.onlyTicketsLeft} $remaining ${AppStrings.ticketsAvailable}';
    case _OfferAvailability.soldOut:
      return AppStrings.soldOut;
  }
}

Color _statusColor(OfferEntity offer) {
  switch (_availabilityFor(offer)) {
    case _OfferAvailability.available:
      return const Color(0xFF2E9A76);
    case _OfferAvailability.low:
      return const Color(0xFFE28B25);
    case _OfferAvailability.soldOut:
      return const Color(0xFFDD5A5A);
  }
}

bool _isSoldOut(OfferEntity offer) {
  return _availabilityFor(offer) == _OfferAvailability.soldOut;
}

_OfferAvailability _availabilityFor(OfferEntity offer) {
  final status = offer.status.toLowerCase().replaceAll(' ', '');
  final remaining = _remainingTotal(offer);
  if (remaining <= 0) return _OfferAvailability.soldOut;
  if (status.contains('soldout') || status.contains('sold_out')) {
    return _OfferAvailability.soldOut;
  }
  if (status.contains('low')) {
    return _OfferAvailability.low;
  }
  if (remaining <= 3) return _OfferAvailability.low;
  return _OfferAvailability.available;
}

enum _OfferAvailability { available, low, soldOut }

int _remainingTotal(OfferEntity offer) {
  final remainingAdult = offer.remainingAdult < 0 ? 0 : offer.remainingAdult;
  final remainingChild = offer.remainingChild < 0 ? 0 : offer.remainingChild;
  return remainingAdult + remainingChild;
}
