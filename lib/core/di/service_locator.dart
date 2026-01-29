import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/home/data/datasources/restaurant_remote_data_source.dart';
import '../../features/home/data/repositories/restaurant_repository_impl.dart';
import '../../features/home/domain/repositories/restaurant_repository.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/bookings/booking_flow/presentation/cubit/booking_flow_cubit.dart';
import '../../features/offers/data/datasources/offer_remote_data_source.dart';
import '../../features/offers/data/repositories/offer_repository_impl.dart';
import '../../features/offers/domain/repositories/offer_repository.dart';
import '../../features/offers/domain/usecases/get_offers_for_date_usecase.dart';
import '../../features/offers/domain/usecases/get_offers_for_range_usecase.dart';
import '../../features/auth/presentation/login/logic/login_cubit.dart';
import '../../features/auth/presentation/forget_password/logic/forget_password_cubit.dart';
import '../../features/auth/presentation/change_password/logic/change_password_cubit.dart';
import '../../features/auth/presentation/otp/logic/otp_cubit.dart';
import '../../features/auth/presentation/registration/logic/register_cubit.dart';
import '../../features/users/data/datasources/user_remote_data_source.dart';
import '../../features/users/data/repositories/user_repository_impl.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import '../../features/users/domain/usecases/create_user_usecase.dart';
import '../../features/users/domain/usecases/get_user_by_id_usecase.dart';
import '../../features/payments/data/datasources/payment_remote_data_source.dart';
import '../../features/payments/data/repositories/payment_repository_impl.dart';
import '../../features/payments/domain/repositories/payment_repository.dart';
import '../../features/payments/domain/usecases/create_payment_usecase.dart';
import '../../features/payments/domain/usecases/get_payment_by_booking_usecase.dart';
import '../../features/restaurants/presentation/cubit/restaurant_detail_cubit.dart';
import '../../features/restaurants/data/datasources/restaurant_remote_data_source.dart'
    as restaurants_ds;
import '../../features/restaurants/data/repositories/restaurant_repository_impl.dart'
    as restaurants_repo;
import '../../features/restaurants/domain/repositories/restaurant_repository.dart'
    as restaurants_domain;
import '../../features/restaurants/domain/usecases/get_restaurant_details_usecase.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(firestore: getIt()),
  );
  getIt.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      repository: getIt(),
      getUserById: getIt(),
      auth: getIt(),
    ),
  );
  getIt.registerLazySingleton<OfferRemoteDataSource>(
    () => OfferRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<OfferRepository>(
    () => OfferRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<GetOffersForDateUseCase>(
    () => GetOffersForDateUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetOffersForRangeUseCase>(
    () => GetOffersForRangeUseCase(getIt()),
  );
  getIt.registerFactory<BookingFlowCubit>(
    () => BookingFlowCubit(
      getOffersForDate: getIt(),
      getOffersForRange: getIt(),
    ),
  );
  getIt.registerFactory<LoginCubit>(() => LoginCubit(auth: getIt()));
  getIt.registerFactory<ForgetPasswordCubit>(
    () => ForgetPasswordCubit(auth: getIt()),
  );
  getIt.registerFactory<ChangePasswordCubit>(() => ChangePasswordCubit());
  getIt.registerFactory<OtpCubit>(() => OtpCubit());
  getIt.registerFactory<RegisterCubit>(
    () => RegisterCubit(auth: getIt(), createUser: getIt()),
  );
  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(firestore: getIt()),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<GetUserByIdUseCase>(
    () => GetUserByIdUseCase(getIt()),
  );
  getIt.registerLazySingleton<CreateUserUseCase>(
    () => CreateUserUseCase(getIt()),
  );
  getIt.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSource(firestore: getIt()),
  );
  getIt.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<GetPaymentByBookingUseCase>(
    () => GetPaymentByBookingUseCase(getIt()),
  );
  getIt.registerLazySingleton<CreatePaymentUseCase>(
    () => CreatePaymentUseCase(getIt()),
  );
  getIt.registerLazySingleton<restaurants_ds.RestaurantRemoteDataSource>(
    () => restaurants_ds.RestaurantRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<restaurants_domain.RestaurantRepository>(
    () => restaurants_repo.RestaurantRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<GetRestaurantDetailsUseCase>(
    () => GetRestaurantDetailsUseCase(getIt()),
  );
  getIt.registerFactory<RestaurantDetailCubit>(
    () => RestaurantDetailCubit(getRestaurantDetails: getIt()),
  );
}
