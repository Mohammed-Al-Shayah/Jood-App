import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import '../../ads/domain/usecases/create_ad_usecase.dart';
import '../../ads/domain/usecases/delete_ad_usecase.dart';
import '../../ads/domain/usecases/get_ads_usecase.dart';
import '../../ads/domain/usecases/update_ad_usecase.dart';
import '../../attractions/domain/usecases/create_attraction_usecase.dart';
import '../../attractions/domain/usecases/delete_attraction_usecase.dart';
import '../../attractions/domain/usecases/get_all_attractions_usecase.dart';
import '../../attractions/domain/usecases/update_attraction_usecase.dart';
import '../../bookings/domain/usecases/get_all_bookings_usecase.dart';
import '../../offers/domain/usecases/create_offer_usecase.dart';
import '../../offers/domain/usecases/delete_offer_usecase.dart';
import '../../offers/domain/usecases/get_offers_usecase.dart';
import '../../offers/domain/usecases/update_offer_usecase.dart';
import '../../restaurants/domain/usecases/create_restaurant_usecase.dart';
import '../../restaurants/domain/usecases/delete_restaurant_usecase.dart';
import '../../restaurants/domain/usecases/get_all_restaurants_usecase.dart';
import '../../restaurants/domain/usecases/update_restaurant_usecase.dart';
import '../../users/domain/usecases/delete_user_usecase.dart';
import '../../users/domain/usecases/get_users_usecase.dart';
import '../../users/domain/usecases/update_user_usecase.dart';
import '../data/datasources/admin_storage_remote_data_source.dart';
import '../data/repositories/admin_storage_repository_impl.dart';
import '../domain/repositories/admin_storage_repository.dart';
import '../domain/usecases/delete_storage_file_usecase.dart';
import '../domain/usecases/upload_ad_image_usecase.dart';
import '../domain/usecases/upload_attraction_image_usecase.dart';
import '../domain/usecases/upload_restaurant_image_usecase.dart';
import '../presentation/cubit/admin_ads_cubit.dart';
import '../presentation/cubit/admin_attractions_cubit.dart';
import '../presentation/cubit/admin_offers_cubit.dart';
import '../presentation/cubit/admin_orders_cubit.dart';
import '../presentation/cubit/admin_overview_cubit.dart';
import '../presentation/cubit/admin_restaurants_cubit.dart';
import '../presentation/cubit/admin_users_cubit.dart';

void registerAdminDependencies(GetIt getIt) {
  getIt.registerLazySingleton<AdminStorageRemoteDataSource>(
    () => AdminStorageRemoteDataSource(getIt<FirebaseStorage>()),
  );
  getIt.registerLazySingleton<AdminStorageRepository>(
    () => AdminStorageRepositoryImpl(getIt<AdminStorageRemoteDataSource>()),
  );
  getIt.registerFactory<AdminRestaurantsCubit>(
    () => AdminRestaurantsCubit(
      getAllRestaurants: getIt<GetAllRestaurantsUseCase>(),
      createRestaurant: getIt<CreateRestaurantUseCase>(),
      updateRestaurant: getIt<UpdateRestaurantUseCase>(),
      deleteRestaurant: getIt<DeleteRestaurantUseCase>(),
    ),
  );
  getIt.registerFactory<AdminAttractionsCubit>(
    () => AdminAttractionsCubit(
      getAllAttractions: getIt<GetAllAttractionsUseCase>(),
      createAttraction: getIt<CreateAttractionUseCase>(),
      updateAttraction: getIt<UpdateAttractionUseCase>(),
      deleteAttraction: getIt<DeleteAttractionUseCase>(),
    ),
  );
  getIt.registerFactory<AdminAdsCubit>(
    () => AdminAdsCubit(
      getAds: getIt<GetAdsUseCase>(),
      createAd: getIt<CreateAdUseCase>(),
      updateAd: getIt<UpdateAdUseCase>(),
      deleteAd: getIt<DeleteAdUseCase>(),
    ),
  );
  getIt.registerFactory<AdminOffersCubit>(
    () => AdminOffersCubit(
      getOffers: getIt<GetOffersUseCase>(),
      createOffer: getIt<CreateOfferUseCase>(),
      updateOffer: getIt<UpdateOfferUseCase>(),
      deleteOffer: getIt<DeleteOfferUseCase>(),
    ),
  );
  getIt.registerFactory<AdminUsersCubit>(
    () => AdminUsersCubit(
      getUsers: getIt<GetUsersUseCase>(),
      updateUser: getIt<UpdateUserUseCase>(),
      deleteUser: getIt<DeleteUserUseCase>(),
    ),
  );
  getIt.registerFactory<AdminOrdersCubit>(
    () =>
        AdminOrdersCubit(getAllRestaurants: getIt<GetAllRestaurantsUseCase>()),
  );
  getIt.registerFactory<AdminOverviewCubit>(
    () => AdminOverviewCubit(
      getAllRestaurants: getIt<GetAllRestaurantsUseCase>(),
      getOffers: getIt<GetOffersUseCase>(),
      getUsers: getIt<GetUsersUseCase>(),
      getAllBookings: getIt<GetAllBookingsUseCase>(),
    ),
  );
  getIt.registerLazySingleton<UploadRestaurantImageUseCase>(
    () => UploadRestaurantImageUseCase(getIt<AdminStorageRepository>()),
  );
  getIt.registerLazySingleton<UploadAdImageUseCase>(
    () => UploadAdImageUseCase(getIt<AdminStorageRepository>()),
  );
  getIt.registerLazySingleton<UploadAttractionImageUseCase>(
    () => UploadAttractionImageUseCase(getIt<AdminStorageRepository>()),
  );
  getIt.registerLazySingleton<DeleteStorageFileUseCase>(
    () => DeleteStorageFileUseCase(getIt<AdminStorageRepository>()),
  );
}
