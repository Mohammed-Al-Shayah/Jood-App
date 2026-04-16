import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import '../payments/payment_completion_service.dart';
import '../../features/home/data/datasources/restaurant_remote_data_source.dart';
import '../../features/home/data/repositories/restaurant_repository_impl.dart';
import '../../features/home/domain/repositories/restaurant_repository.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/bookings/booking_flow/presentation/cubit/booking_flow_cubit.dart';
import '../../features/bookings/booking_flow/presentation/cubit/payment_screen_cubit.dart';
import '../../features/booking_catalog/data/datasources/catalog_remote_data_source.dart';
import '../../features/booking_catalog/data/repositories/catalog_repository_impl.dart';
import '../../features/booking_catalog/domain/repositories/catalog_repository.dart';
import '../../features/booking_catalog/domain/usecases/get_catalog_items_usecase.dart';
import '../../features/booking_catalog/domain/usecases/watch_catalog_changes_usecase.dart';
import '../../features/booking_catalog/presentation/cubit/catalog_list_cubit.dart';
import '../../features/ads/data/datasources/ad_remote_data_source.dart';
import '../../features/ads/data/repositories/ad_repository_impl.dart';
import '../../features/ads/domain/repositories/ad_repository.dart';
import '../../features/ads/domain/usecases/get_ads_usecase.dart';
import '../../features/ads/domain/usecases/get_active_ads_usecase.dart';
import '../../features/ads/domain/usecases/create_ad_usecase.dart';
import '../../features/ads/domain/usecases/update_ad_usecase.dart';
import '../../features/ads/domain/usecases/delete_ad_usecase.dart';
import '../../features/ads/domain/usecases/watch_ads_changes_usecase.dart';
import '../../features/offers/data/datasources/offer_remote_data_source.dart';
import '../../features/offers/data/repositories/offer_repository_impl.dart';
import '../../features/offers/domain/repositories/offer_repository.dart';
import '../../features/offers/domain/usecases/get_offers_for_date_usecase.dart';
import '../../features/offers/domain/usecases/get_offers_for_range_usecase.dart';
import '../../features/offers/domain/usecases/get_offer_by_id_usecase.dart';
import '../../features/offers/domain/usecases/get_offers_usecase.dart';
import '../../features/offers/domain/usecases/create_offer_usecase.dart';
import '../../features/offers/domain/usecases/update_offer_usecase.dart';
import '../../features/offers/domain/usecases/delete_offer_usecase.dart';
import '../../features/auth/presentation/login/logic/login_cubit.dart';
import '../../features/auth/presentation/forget_password/logic/forget_password_cubit.dart';
import '../../features/auth/presentation/change_password/logic/change_password_cubit.dart';
import '../../features/auth/presentation/registration/logic/register_cubit.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_email_in_use_usecase.dart';
import '../../features/auth/domain/usecases/delete_account_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/link_email_password_usecase.dart';
import '../../features/auth/domain/usecases/login_with_email_usecase.dart';
import '../../features/auth/domain/usecases/reload_user_usecase.dart';
import '../../features/auth/domain/usecases/send_email_verification_usecase.dart';
import '../../features/auth/domain/usecases/send_password_reset_email_usecase.dart';
import '../../features/auth/domain/usecases/send_phone_otp_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/update_password_usecase.dart';
import '../../features/auth/domain/usecases/verify_before_update_email_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/domain/usecases/watch_auth_state_changes_usecase.dart';
import '../../features/users/data/datasources/user_remote_data_source.dart';
import '../../features/users/data/repositories/user_repository_impl.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import '../../features/users/domain/usecases/get_user_by_id_usecase.dart';
import '../../features/users/domain/usecases/get_user_by_email_usecase.dart';
import '../../features/users/domain/usecases/get_user_by_phone_usecase.dart';
import '../../features/users/domain/usecases/create_user_usecase.dart';
import '../../features/users/domain/usecases/sync_auth_user_usecase.dart';
import '../../features/users/domain/usecases/update_user_usecase.dart';
import '../../features/users/domain/usecases/get_users_usecase.dart';
import '../../features/users/domain/usecases/delete_user_usecase.dart';
import '../../features/users/presentation/cubit/profile_cubit.dart';
import '../../features/payments/data/datasources/payment_remote_data_source.dart';
import '../../features/payments/data/repositories/payment_repository_impl.dart';
import '../../features/payments/domain/repositories/payment_repository.dart';
import '../../features/payments/domain/usecases/create_payment_usecase.dart';
import '../../features/payments/domain/usecases/get_payment_by_booking_usecase.dart';
import '../../features/bookings/data/datasources/booking_remote_data_source.dart';
import '../../features/bookings/data/repositories/booking_repository_impl.dart'
    as bookings_repo;
import '../../features/bookings/domain/repositories/booking_repository.dart'
    as bookings_domain;
import '../../features/bookings/domain/usecases/complete_booking_usecase.dart';
import '../../features/bookings/domain/usecases/create_booking_usecase.dart';
import '../../features/bookings/domain/usecases/cancel_booking_usecase.dart';
import '../../features/bookings/domain/usecases/get_all_bookings_usecase.dart';
import '../../features/bookings/domain/usecases/get_booking_by_code_usecase.dart';
import '../../features/bookings/domain/usecases/watch_all_bookings_usecase.dart';
import '../../features/bookings/domain/usecases/watch_my_bookings_usecase.dart';
import '../../features/bookings/domain/usecases/update_booking_refund_status_usecase.dart';
import '../../features/bookings/presentation/cubit/order_qr_scanner_cubit.dart';
import '../../features/bookings/presentation/cubit/orders_cubit.dart';
import '../../features/restaurants/presentation/cubit/restaurant_detail_cubit.dart';
import '../../features/restaurants/data/datasources/restaurant_remote_data_source.dart'
    as restaurants_ds;
import '../../features/restaurants/data/repositories/restaurant_repository_impl.dart'
    as restaurants_repo;
import '../../features/restaurants/domain/repositories/restaurant_repository.dart'
    as restaurants_domain;
import '../../features/restaurants/domain/usecases/get_restaurant_details_usecase.dart';
import '../../features/restaurants/domain/usecases/get_all_restaurants_usecase.dart';
import '../../features/restaurants/domain/usecases/create_restaurant_usecase.dart';
import '../../features/restaurants/domain/usecases/update_restaurant_usecase.dart';
import '../../features/restaurants/domain/usecases/delete_restaurant_usecase.dart';
import '../../features/attractions/data/datasources/attraction_remote_data_source.dart';
import '../../features/attractions/data/repositories/attraction_repository_impl.dart';
import '../../features/attractions/domain/repositories/attraction_repository.dart';
import '../../features/attractions/domain/usecases/get_all_attractions_usecase.dart';
import '../../features/attractions/domain/usecases/create_attraction_usecase.dart';
import '../../features/attractions/domain/usecases/update_attraction_usecase.dart';
import '../../features/attractions/domain/usecases/delete_attraction_usecase.dart';
import '../../features/admin/presentation/cubit/admin_restaurants_cubit.dart';
import '../../features/admin/presentation/cubit/admin_attractions_cubit.dart';
import '../../features/admin/presentation/cubit/admin_ads_cubit.dart';
import '../../features/admin/presentation/cubit/admin_offers_cubit.dart';
import '../../features/admin/presentation/cubit/admin_users_cubit.dart';
import '../../features/admin/presentation/cubit/admin_orders_cubit.dart';
import '../../features/admin/presentation/cubit/admin_overview_cubit.dart';
import '../../features/admin/data/datasources/admin_storage_remote_data_source.dart';
import '../../features/admin/domain/usecases/delete_storage_file_usecase.dart';
import '../../features/admin/domain/usecases/upload_ad_image_usecase.dart';
import '../../features/admin/domain/usecases/upload_attraction_image_usecase.dart';
import '../../features/admin/domain/usecases/upload_restaurant_image_usecase.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFunctions>(
    () => FirebaseFunctions.instance,
  );
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  getIt.registerLazySingleton<AdminStorageRemoteDataSource>(
    () => AdminStorageRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(firestore: getIt()),
  );
  getIt.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      getCatalogItems: getIt(),
      watchCatalogChanges: getIt(),
      getActiveAds: getIt(),
      watchAdsChanges: getIt(),
      getUserById: getIt(),
      getCurrentUser: getIt(),
    ),
  );
  getIt.registerLazySingleton<AdRemoteDataSource>(
    () => AdRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<AdRepository>(() => AdRepositoryImpl(getIt()));
  getIt.registerLazySingleton<GetAdsUseCase>(() => GetAdsUseCase(getIt()));
  getIt.registerLazySingleton<GetActiveAdsUseCase>(
    () => GetActiveAdsUseCase(getIt()),
  );
  getIt.registerLazySingleton<CreateAdUseCase>(() => CreateAdUseCase(getIt()));
  getIt.registerLazySingleton<UpdateAdUseCase>(() => UpdateAdUseCase(getIt()));
  getIt.registerLazySingleton<DeleteAdUseCase>(() => DeleteAdUseCase(getIt()));
  getIt.registerLazySingleton<WatchAdsChangesUseCase>(
    () => WatchAdsChangesUseCase(getIt()),
  );
  getIt.registerLazySingleton<CatalogRemoteDataSource>(
    () => CatalogRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<GetCatalogItemsUseCase>(
    () => GetCatalogItemsUseCase(getIt()),
  );
  getIt.registerLazySingleton<WatchCatalogChangesUseCase>(
    () => WatchCatalogChangesUseCase(getIt()),
  );
  getIt.registerFactory<CatalogListCubit>(
    () => CatalogListCubit(getCatalogItems: getIt()),
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
  getIt.registerLazySingleton<GetOffersUseCase>(
    () => GetOffersUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetOfferByIdUseCase>(
    () => GetOfferByIdUseCase(getIt()),
  );
  getIt.registerLazySingleton<CreateOfferUseCase>(
    () => CreateOfferUseCase(getIt()),
  );
  getIt.registerLazySingleton<UpdateOfferUseCase>(
    () => UpdateOfferUseCase(getIt()),
  );
  getIt.registerLazySingleton<DeleteOfferUseCase>(
    () => DeleteOfferUseCase(getIt()),
  );
  getIt.registerFactory<BookingFlowCubit>(
    () =>
        BookingFlowCubit(getOffersForDate: getIt(), getOffersForRange: getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<LoginWithEmailUseCase>(
    () => LoginWithEmailUseCase(getIt()),
  );
  getIt.registerLazySingleton<CheckEmailInUseUseCase>(
    () => CheckEmailInUseUseCase(getIt()),
  );
  getIt.registerLazySingleton<SendPhoneOtpUseCase>(
    () => SendPhoneOtpUseCase(getIt()),
  );
  getIt.registerLazySingleton<VerifyOtpUseCase>(
    () => VerifyOtpUseCase(getIt()),
  );
  getIt.registerLazySingleton<SendPasswordResetEmailUseCase>(
    () => SendPasswordResetEmailUseCase(getIt()),
  );
  getIt.registerLazySingleton<SendEmailVerificationUseCase>(
    () => SendEmailVerificationUseCase(getIt()),
  );
  getIt.registerLazySingleton<SignOutUseCase>(() => SignOutUseCase(getIt()));
  getIt.registerLazySingleton<WatchAuthStateChangesUseCase>(
    () => WatchAuthStateChangesUseCase(getIt()),
  );
  getIt.registerLazySingleton<DeleteAccountUseCase>(
    () => DeleteAccountUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(getIt()),
  );
  getIt.registerLazySingleton<ReloadUserUseCase>(
    () => ReloadUserUseCase(getIt()),
  );
  getIt.registerLazySingleton<LinkEmailPasswordUseCase>(
    () => LinkEmailPasswordUseCase(getIt()),
  );
  getIt.registerLazySingleton<UpdatePasswordUseCase>(
    () => UpdatePasswordUseCase(getIt()),
  );
  getIt.registerLazySingleton<VerifyBeforeUpdateEmailUseCase>(
    () => VerifyBeforeUpdateEmailUseCase(getIt()),
  );
  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(
      loginWithEmail: getIt(),
      sendEmailVerification: getIt(),
      signOut: getIt(),
      getCurrentUser: getIt(),
      reloadUser: getIt(),
      getUserByPhone: getIt(),
      syncAuthUser: getIt(),
    ),
  );
  getIt.registerFactory<ForgetPasswordCubit>(
    () => ForgetPasswordCubit(
      sendPhoneOtp: getIt(),
      sendPasswordResetEmail: getIt(),
      getUserByPhone: getIt(),
    ),
  );
  getIt.registerFactory<ChangePasswordCubit>(
    () => ChangePasswordCubit(
      getCurrentUser: getIt(),
      updatePassword: getIt(),
      signOut: getIt(),
    ),
  );
  getIt.registerFactory<RegisterCubit>(
    () => RegisterCubit(
      checkEmailInUse: getIt(),
      sendPhoneOtp: getIt(),
      getUserByEmail: getIt(),
      getUserByPhone: getIt(),
    ),
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
  getIt.registerLazySingleton<GetUserByEmailUseCase>(
    () => GetUserByEmailUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetUserByPhoneUseCase>(
    () => GetUserByPhoneUseCase(getIt()),
  );
  getIt.registerLazySingleton<CreateUserUseCase>(
    () => CreateUserUseCase(getIt()),
  );
  getIt.registerLazySingleton<UpdateUserUseCase>(
    () => UpdateUserUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetUsersUseCase>(() => GetUsersUseCase(getIt()));
  getIt.registerLazySingleton<DeleteUserUseCase>(
    () => DeleteUserUseCase(getIt()),
  );
  getIt.registerLazySingleton<SyncAuthUserUseCase>(
    () => SyncAuthUserUseCase(
      getUserById: getIt(),
      createUser: getIt(),
      updateUser: getIt(),
    ),
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
  getIt.registerLazySingleton<PaymentCompletionService>(
    () => PaymentCompletionService(
      createBooking: getIt(),
      createPayment: getIt(),
    ),
  );
  getIt.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<bookings_domain.BookingRepository>(
    () => bookings_repo.BookingRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<CreateBookingUseCase>(
    () => CreateBookingUseCase(getIt<bookings_domain.BookingRepository>()),
  );
  getIt.registerLazySingleton<WatchMyBookingsUseCase>(
    () => WatchMyBookingsUseCase(getIt<bookings_domain.BookingRepository>()),
  );
  getIt.registerLazySingleton<CancelBookingUseCase>(
    () => CancelBookingUseCase(getIt<bookings_domain.BookingRepository>()),
  );
  getIt.registerLazySingleton<GetBookingByCodeUseCase>(
    () => GetBookingByCodeUseCase(getIt<bookings_domain.BookingRepository>()),
  );
  getIt.registerLazySingleton<CompleteBookingUseCase>(
    () => CompleteBookingUseCase(getIt<bookings_domain.BookingRepository>()),
  );
  getIt.registerLazySingleton<GetAllBookingsUseCase>(
    () => GetAllBookingsUseCase(getIt<bookings_domain.BookingRepository>()),
  );
  getIt.registerLazySingleton<WatchAllBookingsUseCase>(
    () => WatchAllBookingsUseCase(getIt<bookings_domain.BookingRepository>()),
  );
  getIt.registerLazySingleton<UpdateBookingRefundStatusUseCase>(
    () => UpdateBookingRefundStatusUseCase(
      getIt<bookings_domain.BookingRepository>(),
    ),
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
  getIt.registerLazySingleton<GetAllRestaurantsUseCase>(
    () => GetAllRestaurantsUseCase(getIt()),
  );
  getIt.registerLazySingleton<CreateRestaurantUseCase>(
    () => CreateRestaurantUseCase(getIt()),
  );
  getIt.registerLazySingleton<UpdateRestaurantUseCase>(
    () => UpdateRestaurantUseCase(getIt()),
  );
  getIt.registerLazySingleton<DeleteRestaurantUseCase>(
    () => DeleteRestaurantUseCase(getIt()),
  );
  getIt.registerLazySingleton<AttractionRemoteDataSource>(
    () => AttractionRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<AttractionRepository>(
    () => AttractionRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<GetAllAttractionsUseCase>(
    () => GetAllAttractionsUseCase(getIt()),
  );
  getIt.registerLazySingleton<CreateAttractionUseCase>(
    () => CreateAttractionUseCase(getIt()),
  );
  getIt.registerLazySingleton<UpdateAttractionUseCase>(
    () => UpdateAttractionUseCase(getIt()),
  );
  getIt.registerLazySingleton<DeleteAttractionUseCase>(
    () => DeleteAttractionUseCase(getIt()),
  );
  getIt.registerFactory<RestaurantDetailCubit>(
    () => RestaurantDetailCubit(getRestaurantDetails: getIt()),
  );
  getIt.registerFactory<OrdersCubit>(
    () => OrdersCubit(
      getCurrentUser: getIt(),
      watchMyBookings: getIt(),
      cancelBooking: getIt(),
      getAllRestaurants: getIt(),
      getAllAttractions: getIt(),
    ),
  );
  getIt.registerFactory<OrderQrScannerCubit>(
    () => OrderQrScannerCubit(
      getCurrentUser: getIt(),
      getUserById: getIt(),
      getBookingByCode: getIt(),
      completeBooking: getIt(),
      getRestaurantDetails: getIt(),
      getOfferById: getIt(),
    ),
  );
  getIt.registerFactory<PaymentScreenCubit>(
    () => PaymentScreenCubit(
      getCurrentUser: getIt(),
      paymentCompletionService: getIt(),
    ),
  );
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      getUserById: getIt(),
      updateUser: getIt(),
      getCurrentUser: getIt(),
      reloadUser: getIt(),
      signOut: getIt(),
      deleteAccount: getIt(),
    ),
  );
  getIt.registerFactory<AdminRestaurantsCubit>(
    () => AdminRestaurantsCubit(
      getAllRestaurants: getIt(),
      createRestaurant: getIt(),
      updateRestaurant: getIt(),
      deleteRestaurant: getIt(),
    ),
  );
  getIt.registerFactory<AdminAttractionsCubit>(
    () => AdminAttractionsCubit(
      getAllAttractions: getIt(),
      createAttraction: getIt(),
      updateAttraction: getIt(),
      deleteAttraction: getIt(),
    ),
  );
  getIt.registerFactory<AdminAdsCubit>(
    () => AdminAdsCubit(
      getAds: getIt(),
      createAd: getIt(),
      updateAd: getIt(),
      deleteAd: getIt(),
    ),
  );
  getIt.registerFactory<AdminOffersCubit>(
    () => AdminOffersCubit(
      getOffers: getIt(),
      createOffer: getIt(),
      updateOffer: getIt(),
      deleteOffer: getIt(),
    ),
  );
  getIt.registerFactory<AdminUsersCubit>(
    () => AdminUsersCubit(
      getUsers: getIt(),
      updateUser: getIt(),
      deleteUser: getIt(),
    ),
  );
  getIt.registerFactory<AdminOrdersCubit>(
    () => AdminOrdersCubit(getAllRestaurants: getIt()),
  );
  getIt.registerFactory<AdminOverviewCubit>(
    () => AdminOverviewCubit(
      getAllRestaurants: getIt(),
      getOffers: getIt(),
      getUsers: getIt(),
      getAllBookings: getIt(),
    ),
  );
  getIt.registerLazySingleton<UploadRestaurantImageUseCase>(
    () => UploadRestaurantImageUseCase(getIt()),
  );
  getIt.registerLazySingleton<UploadAdImageUseCase>(
    () => UploadAdImageUseCase(getIt()),
  );
  getIt.registerLazySingleton<UploadAttractionImageUseCase>(
    () => UploadAttractionImageUseCase(getIt()),
  );
  getIt.registerLazySingleton<DeleteStorageFileUseCase>(
    () => DeleteStorageFileUseCase(getIt()),
  );
}
