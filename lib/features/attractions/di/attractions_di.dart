import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../data/datasources/attraction_remote_data_source.dart';
import '../data/repositories/attraction_repository_impl.dart';
import '../domain/repositories/attraction_repository.dart';
import '../domain/usecases/create_attraction_usecase.dart';
import '../domain/usecases/delete_attraction_usecase.dart';
import '../domain/usecases/get_all_attractions_usecase.dart';
import '../domain/usecases/update_attraction_usecase.dart';

void registerAttractionsDependencies(GetIt getIt) {
  getIt.registerLazySingleton<AttractionRemoteDataSource>(
    () => AttractionRemoteDataSource(getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<AttractionRepository>(
    () => AttractionRepositoryImpl(getIt<AttractionRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetAllAttractionsUseCase>(
    () => GetAllAttractionsUseCase(getIt<AttractionRepository>()),
  );
  getIt.registerLazySingleton<CreateAttractionUseCase>(
    () => CreateAttractionUseCase(getIt<AttractionRepository>()),
  );
  getIt.registerLazySingleton<UpdateAttractionUseCase>(
    () => UpdateAttractionUseCase(getIt<AttractionRepository>()),
  );
  getIt.registerLazySingleton<DeleteAttractionUseCase>(
    () => DeleteAttractionUseCase(getIt<AttractionRepository>()),
  );
}
