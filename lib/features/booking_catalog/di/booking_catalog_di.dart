import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../data/datasources/catalog_remote_data_source.dart';
import '../data/repositories/catalog_repository_impl.dart';
import '../domain/repositories/catalog_repository.dart';
import '../domain/usecases/get_catalog_items_usecase.dart';
import '../domain/usecases/watch_catalog_changes_usecase.dart';
import '../presentation/cubit/catalog_list_cubit.dart';

void registerBookingCatalogDependencies(GetIt getIt) {
  getIt.registerLazySingleton<CatalogRemoteDataSource>(
    () => CatalogRemoteDataSource(getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(getIt<CatalogRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetCatalogItemsUseCase>(
    () => GetCatalogItemsUseCase(getIt<CatalogRepository>()),
  );
  getIt.registerLazySingleton<WatchCatalogChangesUseCase>(
    () => WatchCatalogChangesUseCase(getIt<CatalogRepository>()),
  );
  getIt.registerFactory<CatalogListCubit>(
    () => CatalogListCubit(getCatalogItems: getIt<GetCatalogItemsUseCase>()),
  );
}
