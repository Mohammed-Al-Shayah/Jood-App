import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/app_strings.dart';
import 'package:jood/core/utils/payment_amount_utils.dart';
import 'package:jood/core/routing/app_router.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/config/thawani_config.dart';
import 'package:jood/core/utils/extensions.dart';
import 'package:jood/core/widgets/bottom_cta_bar.dart';
import 'package:jood/features/bookings/domain/usecases/create_booking_usecase.dart';
import 'package:jood/features/payments/domain/entities/payment_entity.dart';
import 'package:jood/features/payments/domain/usecases/create_payment_usecase.dart';
import 'package:thawani_payment/thawani_payment.dart';
import 'package:thawani_payment/models/products.dart';
import '../cubit/booking_flow_cubit.dart';
import '../cubit/booking_flow_state.dart';
import '../widgets/date_utils.dart';
import '../widgets/payment/payment_input_field.dart';
import '../widgets/payment/payment_secure_card.dart';
import '../widgets/payment/payment_summary_card.dart';
import '../widgets/select_date_header.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.restaurantName});

  final String restaurantName;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isSubmitting = false;

  Future<void> _confirmAndPay(BookingFlowState state) async {
    if (_isSubmitting) return;
    final offer = state.selectedOffer();
    if (offer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an offer first.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('You need to login first.')));
      return;
    }
    if (!ThawaniConfig.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Thawani is not configured. Add THAWANI_API_KEY and THAWANI_PUBLISHABLE_KEY.',
          ),
        ),
      );
      return;
    }

    final totalAmount =
        (offer.priceAdult * state.adultCount) +
        (offer.priceChild * state.childCount);
    final totalAmountInBaisa = _toBaisa(totalAmount);

    setState(() => _isSubmitting = true);
    try {
      Thawani.pay(
        context,
        // api: ThawaniConfig.apiKey,
        api: 'rRQ26GcsZzoEhbrP2HZvLYDbn9C9et',
        pKey: 'HGvTMLDssJghr9tlN9gr4DVYt0qyBy',
        // pKey: ThawaniConfig.publishableApiKey,
        metadata: {
          'userId': user.uid,
          'restaurant': widget.restaurantName,
          'offerId': offer.id,
        },
        saveCard: false,
        products: [
          Product(
            name: offer.title.trim().isEmpty
                ? 'Restaurant booking'
                : offer.title,
            quantity: 1,
            unitAmount: totalAmountInBaisa,
          ),
        ],
        clintID: '12345',
        testMode: ThawaniConfig.isTestMode,
        onCreate: (_) {},
        onCancelled: (_) {
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Payment cancelled.')));
        },
        onError: (status) {
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          final message =
              (status['message'] ?? status['error'] ?? 'Payment failed.')
                  .toString();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
        onPaid: (_) {
          unawaited(
            _handlePaymentSuccess(
              state: state,
              userId: user.uid,
              totalAmount: totalAmount,
            ),
          );
        },
      );
    } catch (error) {
      if (!context.mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to start payment: $error')),
      );
    }
  }

  Future<void> _handlePaymentSuccess({
    required BookingFlowState state,
    required String userId,
    required double totalAmount,
  }) async {
    try {
      final offer = state.selectedOffer();
      if (offer == null) throw Exception('Offer not found.');

      final booking = await getIt<CreateBookingUseCase>()(
        offerId: offer.id,
        userId: userId,
        adults: state.adultCount,
        children: state.childCount,
      );

      await getIt<CreatePaymentUseCase>()(
        PaymentEntity(
          id: 'pay_${booking.id}_${DateTime.now().millisecondsSinceEpoch}',
          bookingId: booking.id,
          amount: totalAmount,
          status: 'success',
          method: 'thawani',
          createdAt: DateTime.now(),
        ),
      );

      if (!mounted) return;
      context.pushNamed(
        Routes.bookingConfirmedScreen,
        arguments: BookingConfirmedArgs(
          restaurantName: widget.restaurantName,
          cubit: context.read<BookingFlowCubit>(),
          bookingCode: booking.bookingCode,
          qrData: booking.qrPayload,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment was successful but booking save failed. Please contact support. $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  int _toBaisa(double amount) {
    return (amount * 1000).round();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingFlowCubit, BookingFlowState>(
      builder: (context, state) {
        final selectedOffer = state.selectedOffer();
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
          bottomNavigationBar: BottomCtaBar(
            label: _isSubmitting
                ? 'Processing...'
                : '${AppStrings.confirmAndPay} ${formatCurrency(currency, totalAmount)}',
            onPressed: () => _confirmAndPay(state),
            backgroundColor: Colors.white,
            shadowColor: AppColors.shadowColor,
            textStyle: AppTextStyles.cta,
            buttonColor: AppColors.primary,
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
                          restaurantName: widget.restaurantName,
                          timeLabel: summaryTime,
                          totalAmount: formatCurrency(currency, totalAmount),
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
}
