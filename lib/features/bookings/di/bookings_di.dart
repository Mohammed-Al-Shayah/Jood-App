import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../attractions/domain/usecases/get_all_attractions_usecase.dart';
import '../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../offers/domain/usecases/get_offer_by_id_usecase.dart';
import '../../offers/domain/usecases/get_offers_for_date_usecase.dart';
import '../../offers/domain/usecases/get_offers_for_range_usecase.dart';
import '../../restaurants/domain/usecases/get_all_restaurants_usecase.dart';
import '../../restaurants/domain/usecases/get_restaurant_details_usecase.dart';
import '../../users/domain/usecases/get_user_by_id_usecase.dart';
import '../booking_flow/presentation/cubit/booking_flow_cubit.dart';
import '../booking_flow/presentation/cubit/payment_screen_cubit.dart';
import '../data/datasources/booking_remote_data_source.dart';
import '../data/repositories/booking_repository_impl.dart';
import '../domain/repositories/booking_repository.dart';
import '../domain/usecases/cancel_booking_usecase.dart';
import '../domain/usecases/complete_booking_usecase.dart';
import '../domain/usecases/create_booking_usecase.dart';
import '../domain/usecases/delete_booking_usecase.dart';
import '../domain/usecases/get_all_bookings_usecase.dart';
import '../domain/usecases/get_booking_by_code_usecase.dart';
import '../domain/usecases/update_booking_refund_status_usecase.dart';
import '../domain/usecases/watch_all_bookings_usecase.dart';
import '../domain/usecases/watch_my_bookings_usecase.dart';
import '../presentation/cubit/order_qr_scanner_cubit.dart';
import '../presentation/cubit/orders_cubit.dart';
import '../../../core/payments/payment_completion_service.dart';

void registerBookingsDependencies(GetIt getIt) {
  getIt.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSource(getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(getIt<BookingRemoteDataSource>()),
  );
  getIt.registerLazySingleton<CreateBookingUseCase>(
    () => CreateBookingUseCase(getIt<BookingRepository>()),
  );
  getIt.registerLazySingleton<WatchMyBookingsUseCase>(
    () => WatchMyBookingsUseCase(getIt<BookingRepository>()),
  );
  getIt.registerLazySingleton<CancelBookingUseCase>(
    () => CancelBookingUseCase(getIt<BookingRepository>()),
  );
  getIt.registerLazySingleton<GetBookingByCodeUseCase>(
    () => GetBookingByCodeUseCase(getIt<BookingRepository>()),
  );
  getIt.registerLazySingleton<CompleteBookingUseCase>(
    () => CompleteBookingUseCase(getIt<BookingRepository>()),
  );
  getIt.registerLazySingleton<GetAllBookingsUseCase>(
    () => GetAllBookingsUseCase(getIt<BookingRepository>()),
  );
  getIt.registerLazySingleton<DeleteBookingUseCase>(
    () => DeleteBookingUseCase(getIt<BookingRepository>()),
  );
  getIt.registerLazySingleton<WatchAllBookingsUseCase>(
    () => WatchAllBookingsUseCase(getIt<BookingRepository>()),
  );
  getIt.registerLazySingleton<UpdateBookingRefundStatusUseCase>(
    () => UpdateBookingRefundStatusUseCase(getIt<BookingRepository>()),
  );
  getIt.registerFactory<BookingFlowCubit>(
    () => BookingFlowCubit(
      getOffersForDate: getIt<GetOffersForDateUseCase>(),
      getOffersForRange: getIt<GetOffersForRangeUseCase>(),
    ),
  );
  getIt.registerFactory<OrdersCubit>(
    () => OrdersCubit(
      getCurrentUser: getIt<GetCurrentUserUseCase>(),
      watchMyBookings: getIt<WatchMyBookingsUseCase>(),
      cancelBooking: getIt<CancelBookingUseCase>(),
      getAllRestaurants: getIt<GetAllRestaurantsUseCase>(),
      getAllAttractions: getIt<GetAllAttractionsUseCase>(),
    ),
  );
  getIt.registerFactory<OrderQrScannerCubit>(
    () => OrderQrScannerCubit(
      getCurrentUser: getIt<GetCurrentUserUseCase>(),
      getUserById: getIt<GetUserByIdUseCase>(),
      getBookingByCode: getIt<GetBookingByCodeUseCase>(),
      completeBooking: getIt<CompleteBookingUseCase>(),
      getRestaurantDetails: getIt<GetRestaurantDetailsUseCase>(),
      getOfferById: getIt<GetOfferByIdUseCase>(),
    ),
  );
  getIt.registerFactory<PaymentScreenCubit>(
    () => PaymentScreenCubit(
      getCurrentUser: getIt<GetCurrentUserUseCase>(),
      paymentCompletionService: getIt<PaymentCompletionService>(),
    ),
  );
}
