import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../data/datasources/ad_remote_data_source.dart';
import '../data/repositories/ad_repository_impl.dart';
import '../domain/repositories/ad_repository.dart';
import '../domain/usecases/create_ad_usecase.dart';
import '../domain/usecases/delete_ad_usecase.dart';
import '../domain/usecases/get_active_ads_usecase.dart';
import '../domain/usecases/get_ads_usecase.dart';
import '../domain/usecases/update_ad_usecase.dart';
import '../domain/usecases/watch_ads_changes_usecase.dart';

void registerAdsDependencies(GetIt getIt) {
  getIt.registerLazySingleton<AdRemoteDataSource>(
    () => AdRemoteDataSource(getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<AdRepository>(
    () => AdRepositoryImpl(getIt<AdRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetAdsUseCase>(
    () => GetAdsUseCase(getIt<AdRepository>()),
  );
  getIt.registerLazySingleton<GetActiveAdsUseCase>(
    () => GetActiveAdsUseCase(getIt<AdRepository>()),
  );
  getIt.registerLazySingleton<CreateAdUseCase>(
    () => CreateAdUseCase(getIt<AdRepository>()),
  );
  getIt.registerLazySingleton<UpdateAdUseCase>(
    () => UpdateAdUseCase(getIt<AdRepository>()),
  );
  getIt.registerLazySingleton<DeleteAdUseCase>(
    () => DeleteAdUseCase(getIt<AdRepository>()),
  );
  getIt.registerLazySingleton<WatchAdsChangesUseCase>(
    () => WatchAdsChangesUseCase(getIt<AdRepository>()),
  );
}
