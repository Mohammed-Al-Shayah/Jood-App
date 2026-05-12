import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../data/datasources/restaurant_remote_data_source.dart';
import '../data/repositories/restaurant_repository_impl.dart';
import '../domain/repositories/restaurant_repository.dart';
import '../domain/usecases/create_restaurant_usecase.dart';
import '../domain/usecases/delete_restaurant_usecase.dart';
import '../domain/usecases/get_all_restaurants_usecase.dart';
import '../domain/usecases/get_restaurant_details_usecase.dart';
import '../domain/usecases/update_restaurant_usecase.dart';
import '../presentation/cubit/restaurant_detail_cubit.dart';

void registerRestaurantsDependencies(GetIt getIt) {
  getIt.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSource(getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(getIt<RestaurantRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetRestaurantDetailsUseCase>(
    () => GetRestaurantDetailsUseCase(getIt<RestaurantRepository>()),
  );
  getIt.registerLazySingleton<GetAllRestaurantsUseCase>(
    () => GetAllRestaurantsUseCase(getIt<RestaurantRepository>()),
  );
  getIt.registerLazySingleton<CreateRestaurantUseCase>(
    () => CreateRestaurantUseCase(getIt<RestaurantRepository>()),
  );
  getIt.registerLazySingleton<UpdateRestaurantUseCase>(
    () => UpdateRestaurantUseCase(getIt<RestaurantRepository>()),
  );
  getIt.registerLazySingleton<DeleteRestaurantUseCase>(
    () => DeleteRestaurantUseCase(getIt<RestaurantRepository>()),
  );
  getIt.registerFactory<RestaurantDetailCubit>(
    () => RestaurantDetailCubit(
      getRestaurantDetails: getIt<GetRestaurantDetailsUseCase>(),
    ),
  );
}
