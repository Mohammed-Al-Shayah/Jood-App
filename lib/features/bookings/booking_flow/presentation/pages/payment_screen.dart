import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/config/thawani_config.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/payments/payment_verification_service.dart';
import 'package:jood/core/payments/thawani_session_parser.dart';
import 'package:jood/core/routing/app_router.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/app_strings.dart';
import 'package:jood/core/utils/extensions.dart';
import 'package:jood/core/utils/payment_amount_utils.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/core/widgets/bottom_cta_bar.dart';
import 'package:jood/features/bookings/booking_flow/presentation/cubit/booking_flow_cubit.dart';
import 'package:jood/features/bookings/booking_flow/presentation/cubit/booking_flow_state.dart';
import 'package:jood/features/bookings/booking_flow/presentation/cubit/payment_screen_cubit.dart';
import 'package:jood/features/bookings/booking_flow/presentation/cubit/payment_screen_state.dart';
import 'package:jood/features/bookings/booking_flow/presentation/models/booking_amounts_view_model.dart';
import 'package:jood/features/bookings/booking_flow/presentation/models/payment_error_view_model.dart';
import 'package:jood/features/bookings/booking_flow/presentation/widgets/booking_confirmed/booking_confirmed_utils.dart';
import 'package:jood/features/bookings/booking_flow/presentation/widgets/date_utils.dart';
import 'package:jood/features/bookings/booking_flow/presentation/widgets/payment/payment_secure_card.dart';
import 'package:jood/features/bookings/booking_flow/presentation/widgets/payment/payment_summary_card.dart';
import 'package:jood/features/bookings/booking_flow/presentation/widgets/select_date_header.dart';
import 'package:thawani_payment/models/products.dart';
import 'package:thawani_payment/thawani_payment.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.restaurantName});

  final String restaurantName;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with WidgetsBindingObserver, RouteAware {
  final _formKey = GlobalKey<FormState>();
  late final PaymentScreenCubit _paymentCubit = getIt<PaymentScreenCubit>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirectGuestToLoginIfNeeded();
      _checkPendingPayment();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    unawaited(PaymentVerificationService.clearPending());
    unawaited(_paymentCubit.close());
    super.dispose();
  }

  @override
  void didPopNext() {
    if (_paymentCubit.state.isSubmitting) {
      _paymentCubit.stopSubmitting();
      _checkPendingPayment();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _checkPendingPayment();
    }
  }

  void _redirectGuestToLoginIfNeeded() {
    if (!_paymentCubit.markGuestRedirectHandled()) return;
    if (_paymentCubit.hasAuthenticatedUser || !mounted) return;

    showAppSnackBar(
      context,
      AppStrings.pleaseLoginFirst,
      type: SnackBarType.error,
    );
    context.pushNamed(Routes.loginScreen);
  }

  Future<void> _checkPendingPayment() {
    return PaymentVerificationService.checkAndHandlePendingPayment(
      context,
      cubit: context.read<BookingFlowCubit>(),
    );
  }

  Future<void> _confirmAndPay() async {
    if (_paymentCubit.state.isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final bookingFlowCubit = context.read<BookingFlowCubit>();
    PreparedPaymentLaunch checkout;
    try {
      checkout = await _paymentCubit.prepareCheckout(
        bookingFlowCubit: bookingFlowCubit,
      );
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '').trim();
      showAppSnackBar(context, message, type: SnackBarType.error);
      if (!_paymentCubit.hasAuthenticatedUser) {
        context.pushNamed(Routes.loginScreen);
      }
      return;
    }

    _paymentCubit.beginPaymentAttempt();
    await PaymentVerificationService.clearPending();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    try {
      Thawani.pay(
        context,
        api: ThawaniConfig.apiKey,
        pKey: ThawaniConfig.publishableApiKey,
        testMode: false,
        successUrl: 'joodapp://success',
        cancelUrl: 'joodapp://cancel',
        metadata: {
          'userId': checkout.userId,
          'restaurant': widget.restaurantName,
          'offerId': checkout.offerId,
        },
        saveCard: false,
        products: [
          Product(
            name: checkout.offerTitle,
            quantity: 1,
            unitAmount: checkout.totalAmountInBaisa,
          ),
        ],
        clintID: checkout.userId,
        onCreate: (session) async {
          final sessionId = ThawaniSessionParser.extractSessionId(session);
          if (sessionId == null || sessionId.isEmpty) {
            return;
          }
          await _paymentCubit.savePendingPayment(
            checkout: checkout,
            restaurantName: widget.restaurantName,
            sessionId: sessionId,
          );
        },
        onCancelled: (_) async {
          if (!mounted) return;
          _paymentCubit.stopSubmitting();
          showAppSnackBar(context, AppStrings.paymentCancelled);
          await _checkPendingPayment();
        },
        onError: (status) async {
          if (!mounted) return;
          _paymentCubit.stopSubmitting();
          final message = PaymentErrorViewModel.fromStatus(
            status,
          ).toDisplayMessage();
          showAppSnackBar(context, message, type: SnackBarType.error);
          await _checkPendingPayment();
        },
        onPaid: (_) {
          if (!_paymentCubit.markPaymentSuccessHandled()) return;
          unawaited(_handlePaymentSuccess(checkout));
        },
      );
    } catch (error) {
      if (!mounted) return;
      _paymentCubit.stopSubmitting();
      showAppSnackBar(
        context,
        context.tr('unable_to_start_payment', params: {'error': error}),
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _handlePaymentSuccess(PreparedPaymentLaunch checkout) async {
    try {
      EasyLoading.show(status: AppStrings.processing);
      final completion = await _paymentCubit.finalizePayment(checkout);

      if (!mounted) return;
      showAppSnackBar(
        context,
        AppStrings.paymentCompletedSuccessfully,
        type: SnackBarType.success,
      );
      context.pushReplacementNamed(
        Routes.bookingConfirmedScreen,
        arguments: BookingConfirmedArgs(
          restaurantName: widget.restaurantName,
          cubit: context.read<BookingFlowCubit>(),
          bookingCode: completion.booking.bookingCode,
          qrData: completion.booking.qrPayload,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        context.tr(
          'payment_completed_but_booking_save_failed',
          params: {'error': error},
        ),
        type: SnackBarType.error,
      );
    } finally {
      EasyLoading.dismiss();
      _paymentCubit.stopSubmitting();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _paymentCubit,
      child: BlocBuilder<PaymentScreenCubit, PaymentScreenState>(
        builder: (context, paymentState) {
          return Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar:
                BlocSelector<
                  BookingFlowCubit,
                  BookingFlowState,
                  ({String currency, double totalPayable})
                >(
                  selector: (state) {
                    final selectedOffer = state.selectedOffer();
                    final amounts = BookingAmountsViewModel.calculate(
                      adultPrice: selectedOffer?.priceAdult ?? 0,
                      childPrice: selectedOffer?.priceChild ?? 0,
                      adultOriginalPrice:
                          selectedOffer?.priceAdultOriginal ?? 0,
                      adultCount: state.adultCount,
                      childCount: state.childCount,
                    );
                    return (
                      currency: selectedOffer?.currency ?? r'$',
                      totalPayable: amounts.totalPayable,
                    );
                  },
                  builder: (context, vm) {
                    return BottomCtaBar(
                      label: paymentState.isSubmitting
                          ? AppStrings.processing
                          : '${AppStrings.confirmAndPay} ${formatCurrency(vm.currency, vm.totalPayable)}',
                      onPressed: paymentState.isSubmitting
                          ? null
                          : _confirmAndPay,
                      backgroundColor: Colors.white,
                      shadowColor: AppColors.shadowColor,
                      textStyle: AppTextStyles.cta,
                      buttonColor: AppColors.primary,
                    );
                  },
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BlocSelector<
                              BookingFlowCubit,
                              BookingFlowState,
                              ({
                                String summaryTime,
                                String currency,
                                double totalPayable,
                                String guestsLabel,
                              })
                            >(
                              selector: (state) {
                                final selectedOffer = state.selectedOffer();
                                final summaryTime = _buildSummaryLabel(
                                  state.selectedDate,
                                  selectedOffer,
                                );
                                final amounts =
                                    BookingAmountsViewModel.calculate(
                                      adultPrice:
                                          selectedOffer?.priceAdult ?? 0,
                                      childPrice:
                                          selectedOffer?.priceChild ?? 0,
                                      adultOriginalPrice:
                                          selectedOffer?.priceAdultOriginal ??
                                          0,
                                      adultCount: state.adultCount,
                                      childCount: state.childCount,
                                    );
                                return (
                                  summaryTime: summaryTime,
                                  currency: selectedOffer?.currency ?? r'$',
                                  totalPayable: amounts.totalPayable,
                                  guestsLabel: buildGuestsLabel(
                                    state.adultCount,
                                    state.childCount,
                                    bookableType:
                                        selectedOffer?.bookableType ?? '',
                                  ),
                                );
                              },
                              builder: (context, vm) {
                                return PaymentSummaryCard(
                                  restaurantName: widget.restaurantName,
                                  timeLabel: vm.summaryTime,
                                  totalAmount: formatCurrency(
                                    vm.currency,
                                    vm.totalPayable,
                                  ),
                                  guestsLabel: vm.guestsLabel,
                                );
                              },
                            ),
                            SizedBox(height: 18.h),
                            const PaymentSecureCard(),
                          ],
                        ),
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
}

String _buildSummaryLabel(DateTime date, dynamic selectedOffer) {
  final dateLabel = formatOfferDate(date);
  if (selectedOffer == null) return dateLabel;
  final parts = <String>[dateLabel];
  final timeLabel = _buildTimeLabel(selectedOffer);
  final optionLabel = _buildOptionLabel(selectedOffer);
  if (timeLabel.isNotEmpty) parts.add(timeLabel);
  if (optionLabel.isNotEmpty && optionLabel != timeLabel) {
    parts.add(optionLabel);
  }
  return parts.join(' | ');
}

String _buildTimeLabel(dynamic offer) {
  final start = (offer.startTime as String? ?? '').trim();
  final end = (offer.endTime as String? ?? '').trim();
  if (start.isEmpty && end.isEmpty) return '';
  if (start.isEmpty) return end;
  if (end.isEmpty) return start;
  return '$start - $end';
}

String _buildOptionLabel(dynamic offer) {
  final packageName = (offer.packageName as String? ?? '').trim();
  if (packageName.isNotEmpty) return packageName;
  final mealType = (offer.mealType as String? ?? '').trim();
  if (mealType.isNotEmpty) {
    return mealType
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
  return (offer.title as String? ?? '').trim();
}
