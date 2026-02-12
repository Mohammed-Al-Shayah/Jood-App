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
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/core/payments/payment_verification_service.dart';
import 'package:jood/core/widgets/bottom_cta_bar.dart';
import 'package:jood/features/bookings/domain/usecases/create_booking_usecase.dart';
import 'package:jood/features/payments/domain/entities/payment_entity.dart';
import 'package:jood/features/payments/domain/usecases/create_payment_usecase.dart';
import 'package:thawani_payment/thawani_payment.dart';
import 'package:thawani_payment/models/products.dart';
import '../cubit/booking_flow_cubit.dart';
import '../cubit/booking_flow_state.dart';
import '../models/booking_amounts_view_model.dart';
import '../models/payment_error_view_model.dart';
import '../widgets/date_utils.dart';
import '../widgets/payment/payment_secure_card.dart';
import '../widgets/payment/payment_summary_card.dart';
import '../widgets/select_date_header.dart';
import 'dart:convert';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.restaurantName});

  final String restaurantName;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with WidgetsBindingObserver, RouteAware {
  bool _isSubmitting = false;
  bool _guestRedirectHandled = false;
  bool _paymentSuccessHandled = false;
  final _formKey = GlobalKey<FormState>();
  final _cardholderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirectGuestToLoginIfNeeded();
      PaymentVerificationService.checkAndHandlePendingPayment(
        context,
        cubit: context.read<BookingFlowCubit>(),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // نقوم بتسجيل هذه الصفحة لكي يراقبها الـ RouteObserver
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _cardholderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();

    // 🔥 إضافة جديدة وهامة:
    // تنظيف أي عملية دفع معلقة بمجرد تدمير هذه الصفحة
    // هذا يضمن أنه لو عاد المستخدم لصفحة الضيوف ثم دخل للدفع مرة أخرى، يبدأ من الصفر نظيفاً
    PaymentVerificationService.clearPending();

    super.dispose();
  }

  @override
  void didPopNext() {
    print(
      "🔄 User returned to Payment Screen (Webview closed via Back button)",
    );

    // إذا كان الزر ما زال معلقاً (Processing)، نقوم بإعادته للوضع الطبيعي
    if (_isSubmitting) {
      setState(() => _isSubmitting = false);

      // ونقوم فوراً بالتحقق من السيرفر، ربما دفع المستخدم ثم ضغط رجوع بسرعة
      PaymentVerificationService.checkAndHandlePendingPayment(
        context,
        cubit: context.read<BookingFlowCubit>(),
      );
    }
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

  void _redirectGuestToLoginIfNeeded() {
    if (_guestRedirectHandled || !mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) return;

    _guestRedirectHandled = true;
    showAppSnackBar(
      context,
      'You need to login first.',
      type: SnackBarType.error,
    );
    context.pushNamed(Routes.loginScreen);
  }

  Future<void> _confirmAndPay() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final state = context.read<BookingFlowCubit>().state;
    final offer = state.selectedOffer();
    if (offer == null) {
      showAppSnackBar(
        context,
        'Please select an offer first.',
        type: SnackBarType.error,
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showAppSnackBar(
        context,
        'You need to login first.',
        type: SnackBarType.error,
      );
      context.pushNamed(Routes.loginScreen);
      return;
    }
    if (!ThawaniConfig.isConfigured) {
      showAppSnackBar(
        context,
        'Thawani is not configured. Add THAWANI_API_KEY and THAWANI_PUBLISHABLE_KEY.',
        type: SnackBarType.error,
      );
      return;
    }

    final amounts = BookingAmountsViewModel.calculate(
      adultPrice: offer.priceAdult,
      childPrice: offer.priceChild,
      adultOriginalPrice: offer.priceAdultOriginal,
      adultCount: state.adultCount,
      childCount: state.childCount,
    );
    final totalPayable = amounts.totalPayable;
    final totalAmountInBaisa = _toBaisa(totalPayable);

    setState(() => _isSubmitting = true);
    print("🧹 START: Clearing any stale payment data...");
    await PaymentVerificationService.clearPending();

    // تأخير بسيط جداً لضمان انتهاء عملية المسح
    await Future.delayed(const Duration(milliseconds: 100));
    // 🔥🔥🔥 انتهى التعديل 🔥🔥🔥
    try {
      await Thawani.pay(
        context,
        api: ThawaniConfig.apiKey,
        // api: 'rRQ26GcsZzoEhbrP2HZvLYDbn9C9et',
        // pKey: 'HGvTMLDssJghr9tlN9gr4DVYt0qyBy',
        pKey: ThawaniConfig.publishableApiKey,
        testMode: false,
        successUrl: "joodapp://success",
        cancelUrl: "joodapp://cancel",

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
        clintID: user.uid,
        // testMode: ThawaniConfig.isTestMode,
        onCreate: (session) async {
          final sessionId = _extractSessionId(session);
          print("🔥🔥🔥 EXTRACTED SESSION ID: $sessionId");
          if (sessionId == null || sessionId.isEmpty) {
            print("❌ Error: Session ID is null or empty!");
            return;
          }
          await PaymentVerificationService.savePending(
            PendingPayment(
              sessionId: sessionId,
              offerId: offer.id,
              userId: user.uid,
              adults: state.adultCount,
              children: state.childCount,
              totalAmount: totalPayable,
              restaurantName: widget.restaurantName,
            ),
          );
        },
        onCancelled: (_) async {
          // if (!mounted) return;
          // setState(() => _isSubmitting = false);
          // showAppSnackBar(context, 'Payment cancelled.');
          // PaymentVerificationService.clearPending();
          print("⚠️ Debug: تم استدعاء onCancelled - المستخدم أغلق الصفحة");

          // تأكد أن هذا السطر موجود
          print("⚠️ Debug: جاري التحقق من السيرفر قبل الإلغاء...");
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          showAppSnackBar(context, 'Payment cancelled.');

          await PaymentVerificationService.checkAndHandlePendingPayment(
            context,
            cubit: context.read<BookingFlowCubit>(),
          );
          print("⚠️ Debug: انتهى التحقق.");
        },
        onError: (status) async {
          // if (!mounted) return;
          // setState(() => _isSubmitting = false);
          // final message = PaymentErrorViewModel.fromStatus(
          //   status,
          // ).toDisplayMessage();
          // showAppSnackBar(context, message, type: SnackBarType.error);
          // PaymentVerificationService.clearPending();
          if (!mounted) return;

          setState(() => _isSubmitting = false);
          final message = PaymentErrorViewModel.fromStatus(
            status,
          ).toDisplayMessage();
          showAppSnackBar(context, message, type: SnackBarType.error);
          await PaymentVerificationService.checkAndHandlePendingPayment(
            context,
            cubit: context.read<BookingFlowCubit>(),
          );
        },
        onPaid: (_) {
          if (_paymentSuccessHandled) return;
          _paymentSuccessHandled = true;
          PaymentVerificationService.clearPending();
          unawaited(
            _handlePaymentSuccess(
              state: state,
              userId: user.uid,
              totalAmount: totalPayable,
            ),
          );
        },
      );
    } catch (error) {
      if (!context.mounted) return;
      setState(() => _isSubmitting = false);
      showAppSnackBar(
        context,
        'Unable to start payment: $error',
        type: SnackBarType.error,
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
      showAppSnackBar(
        context,
        'Payment completed successfully.',
        type: SnackBarType.success,
      );
      context.pushReplacementNamed(
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
      showAppSnackBar(
        context,
        'Payment was successful but booking save failed. Please contact support. $error',
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String? _extractSessionId(dynamic value) {
    if (value == null) return null;

    // طباعة نوع الكائن للمساعدة في التشخيص
    print("⚠️ Debug: Type of session object: ${value.runtimeType}");

    // محاولة 1: الوصول المباشر عبر dynamic (للكائنات مثل Instance of 'Create')
    try {
      // نفترض أن الكائن لديه خاصية data وبداخلها sessionId (هيكلية ثواني المعتادة)
      // نستخدم dynamic لتجاوز فحص النوع أثناء التجميع
      final dynamic data = (value as dynamic).data;
      if (data != null) {
        // قد يكون data كائناً أيضاً أو Map
        if (data is Map) {
          return data['session_id']?.toString() ??
              data['sessionId']?.toString();
        } else {
          // محاولة الوصول لخاصية داخل كائن data
          try {
            final id = (data as dynamic).sessionId; // أو session_id
            if (id != null) return id.toString();
          } catch (_) {}

          try {
            final id = (data as dynamic).session_id;
            if (id != null) return id.toString();
          } catch (_) {}
        }
      }
    } catch (e) {
      print("⚠️ Debug: Failed to access properties dynamically: $e");
    }

    // محاولة 2: البحث داخل Map (إذا كان خريطة أصلاً)
    if (value is Map) {
      return _searchInMap(value);
    }

    // محاولة 3: تحويل الكائن بالكامل إلى JSON نصي ثم البحث فيه
    // هذه أقوى طريقة إذا كان الكائن يدعم التسلسل (Serialization)
    try {
      // نستخدم jsonEncode لرؤية الهيكلية كاملة
      final jsonString = jsonEncode(value);
      print("⚠️ Debug: Full JSON dump: $jsonString"); // <--- هذا السطر سينقذنا
      final decoded = jsonDecode(jsonString);
      if (decoded is Map) {
        return _searchInMap(decoded);
      }
    } catch (e) {
      print("⚠️ Debug: Failed to encode/decode JSON: $e");
    }

    return null;
  }

  // دالة المساعدة (تأكد أنها موجودة)
  String? _searchInMap(dynamic map) {
    if (map is! Map) return null;
    final castedMap = Map<String, dynamic>.from(map);

    // بحث مباشر
    String? id =
        castedMap['session_id']?.toString() ??
        castedMap['sessionId']?.toString() ??
        castedMap['id']?.toString();
    if (id != null) return id;

    // بحث داخل data
    final data = castedMap['data'];
    if (data is Map) {
      final dataMap = Map<String, dynamic>.from(data);
      return dataMap['session_id']?.toString() ??
          dataMap['sessionId']?.toString() ??
          dataMap['id']?.toString();
    }
    return null;
  }
  // String? _extractSessionId(dynamic value) {
  //   if (value == null) return null;
  //   if (value is String) return value;
  //   if (value is Map) {
  //     final map = Map<String, dynamic>.from(value);
  //     return (map['session_id'] ??
  //             map['sessionId'] ??
  //             map['id'] ??
  //             map['data']?['session_id'] ??
  //             map['data']?['id'])
  //         ?.toString();
  //   }
  //   try {
  //     final json = value.toJson();
  //     if (json is Map) {
  //       final map = Map<String, dynamic>.from(json);
  //       return (map['session_id'] ?? map['sessionId'] ?? map['id'])?.toString();
  //     }
  //   } catch (_) {}
  //   return null;
  // }

  // String? _extractSessionId(dynamic value) {
  //   print("⚠️ Debug: Raw Session Value: $value"); // طباعة القيمة الخام

  //   if (value == null) return null;

  //   // 1. إذا كان مصفوفة أو خريطة، ابحث داخله
  //   if (value is Map) {
  //     return _searchInMap(value);
  //   }

  //   // 2. إذا كان نصًا، حاول تحويله إلى Map أولاً
  //   if (value is String) {
  //     try {
  //       // هل هو نص JSON؟ حاول تحويله
  //       final decoded = jsonDecode(value);
  //       if (decoded is Map) {
  //         return _searchInMap(decoded);
  //       }
  //     } catch (e) {
  //       // ليس JSON، قد يكون هو الـ ID مباشرة (احتمال ضعيف لكن وارد)
  //       print("⚠️ Debug: Value is string but not JSON: $value");
  //       return value.length < 50 ? value : null; // تجاهل النصوص الطويلة جدًا
  //     }
  //   }

  //   // 3. محاولة استخدام toJson (للكائنات)
  //   try {
  //     // ignore: avoid_dynamic_calls
  //     final json = value.toJson();
  //     if (json is Map) {
  //       return _searchInMap(json);
  //     }
  //   } catch (_) {}

  //   return null;
  // }

  // // دالة مساعدة للبحث داخل الـ Map لتجنب التكرار
  // String? _searchInMap(dynamic map) {
  //   if (map is! Map) return null;

  //   final castedMap = Map<String, dynamic>.from(map);

  //   // ابحث في الجذر
  //   String? id =
  //       castedMap['session_id']?.toString() ??
  //       castedMap['sessionId']?.toString() ??
  //       castedMap['id']?.toString();

  //   if (id != null) return id;

  //   // ابحث داخل data (هيكلية ثواني المعتادة)
  //   final data = castedMap['data'];
  //   if (data is Map) {
  //     final dataMap = Map<String, dynamic>.from(data);
  //     return dataMap['session_id']?.toString() ??
  //         dataMap['sessionId']?.toString() ??
  //         dataMap['id']?.toString();
  //   }

  //   return null;
  // }

  int _toBaisa(double amount) {
    return (amount * 1000).round();
  }

  @override
  Widget build(BuildContext context) {
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
                adultOriginalPrice: selectedOffer?.priceAdultOriginal ?? 0,
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
                label: _isSubmitting
                    ? 'Processing...'
                    : '${AppStrings.confirmAndPay} ${formatCurrency(vm.currency, vm.totalPayable)}',
                onPressed: _confirmAndPay,
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
                          int adultsCount,
                          int childrenCount,
                        })
                      >(
                        selector: (state) {
                          final selectedOffer = state.selectedOffer();
                          final dateLabel = formatOfferDate(state.selectedDate);
                          final summaryTime = selectedOffer == null
                              ? dateLabel
                              : '$dateLabel - ${selectedOffer.startTime}';
                          final amounts = BookingAmountsViewModel.calculate(
                            adultPrice: selectedOffer?.priceAdult ?? 0,
                            childPrice: selectedOffer?.priceChild ?? 0,
                            adultOriginalPrice:
                                selectedOffer?.priceAdultOriginal ?? 0,
                            adultCount: state.adultCount,
                            childCount: state.childCount,
                          );
                          return (
                            summaryTime: summaryTime,
                            currency: selectedOffer?.currency ?? r'$',
                            totalPayable: amounts.totalPayable,
                            adultsCount: state.adultCount,
                            childrenCount: state.childCount,
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
                            adultsCount: vm.adultsCount,
                            childrenCount: vm.childrenCount,
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
  }
}
