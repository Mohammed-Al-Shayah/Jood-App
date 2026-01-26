import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/home/data/datasources/restaurant_remote_data_source.dart';
import '../../features/home/data/repositories/restaurant_repository_impl.dart';
import '../../features/home/domain/repositories/restaurant_repository.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';

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
  getIt.registerFactory<HomeCubit>(() => HomeCubit(repository: getIt()));
}
