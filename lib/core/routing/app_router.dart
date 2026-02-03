import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/main_shell/presentation/pages/main_shell_screen.dart';
import '../../features/bookings/presentation/pages/orders_screen.dart';
import '../../features/bookings/presentation/pages/order_qr_scanner_screen.dart';
import '../../features/users/presentation/pages/profile_screen.dart';
import '../../features/auth/presentation/login/page/login.page.dart';
import '../../features/auth/presentation/registration/page/register.page.dart';
import '../../features/auth/presentation/forget_password/pages/forget_password.page.dart';
import '../../features/auth/presentation/otp/page/verify_otp.page.dart';
import '../../features/auth/presentation/otp/verify_otp_args.dart';
import '../../features/auth/presentation/change_password/pages/change_password.page.dart';
import '../../features/auth/presentation/registration/page/request_under_review.page.dart';
import '../../features/auth/presentation/registration/page/beneficiary_create_story.page.dart';
import '../../features/restaurants/presentation/pages/detail_screen.dart';
import '../../features/bookings/booking_flow/presentation/cubit/booking_flow_cubit.dart';
import '../../features/bookings/booking_flow/presentation/pages/booking_confirmed_screen.dart';
import '../../features/bookings/booking_flow/presentation/pages/payment_screen.dart';
import '../../features/bookings/booking_flow/presentation/pages/select_date_time_screen.dart';
import '../../features/bookings/booking_flow/presentation/pages/select_guests_screen.dart';
import 'routes.dart';

class AppRouter {
  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case Routes.registerScreen:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case Routes.forgetPasswordScreen:
        return MaterialPageRoute(builder: (_) => const ForgetPasswordPage());
      case Routes.verifyOtpScreen:
        final args = settings.arguments as VerifyOtpArgs;
        return MaterialPageRoute(builder: (_) => VerifyOtpPage(args: args));
      case Routes.changePasswordScreen:
        return MaterialPageRoute(builder: (_) => const ChangePasswordPage());
      case Routes.requestUnderReviewScreen:
        return MaterialPageRoute(
          builder: (_) => const RequestUnderReviewPage(),
        );
      case Routes.beneficiaryCreateStoryScreen:
        return MaterialPageRoute(
          builder: (_) => const BeneficiaryCreateStoryPage(),
        );
      case Routes.homeScreen:
        return MaterialPageRoute(builder: (_) => const MainShellScreen());
      case Routes.ordersScreen:
        return MaterialPageRoute(builder: (_) => const OrdersScreen());
      case Routes.orderQrScannerScreen:
        return MaterialPageRoute(builder: (_) => const OrderQrScannerScreen());
      case Routes.profileScreen:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case Routes.detailScreen:
        final args = settings.arguments as DetailScreenArgs;
        return MaterialPageRoute(
          builder: (_) => DetailScreen(
            id: args.id,
            name: args.name,
            meta: args.meta,
            rating: args.rating,
            image: args.image,
          ),
        );
      case Routes.selectDateTimeScreen:
        final args = settings.arguments as SelectDateTimeArgs;
        return MaterialPageRoute(
          builder: (_) => SelectDateTimeScreen(
            name: args.name,
            restaurantId: args.restaurantId,
          ),
        );
      case Routes.selectGuestsScreen:
        final args = settings.arguments as SelectGuestsArgs;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: args.cubit,
            child: SelectGuestsScreen(restaurantName: args.restaurantName),
          ),
        );
      case Routes.paymentScreen:
        final args = settings.arguments as PaymentArgs;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: args.cubit,
            child: PaymentScreen(restaurantName: args.restaurantName),
          ),
        );
      case Routes.bookingConfirmedScreen:
        final args = settings.arguments as BookingConfirmedArgs;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: args.cubit,
            child: BookingConfirmedScreen(
              restaurantName: args.restaurantName,
              bookingCode: args.bookingCode,
              qrData: args.qrData,
            ),
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}

class DetailScreenArgs {
  const DetailScreenArgs({
    required this.id,
    required this.name,
    required this.meta,
    required this.rating,
    required this.image,
  });

  final String id;
  final String name;
  final String meta;
  final String rating;
  final Widget image;
}

class SelectDateTimeArgs {
  const SelectDateTimeArgs({required this.restaurantId, required this.name});

  final String restaurantId;
  final String name;
}

class SelectGuestsArgs {
  const SelectGuestsArgs({required this.restaurantName, required this.cubit});

  final String restaurantName;
  final BookingFlowCubit cubit;
}

class PaymentArgs {
  const PaymentArgs({required this.restaurantName, required this.cubit});

  final String restaurantName;
  final BookingFlowCubit cubit;
}

class BookingConfirmedArgs {
  const BookingConfirmedArgs({
    required this.restaurantName,
    required this.cubit,
    this.bookingCode,
    this.qrData,
  });

  final String restaurantName;
  final BookingFlowCubit cubit;
  final String? bookingCode;
  final String? qrData;
}
