import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../data/datasources/offer_remote_data_source.dart';
import '../data/repositories/offer_repository_impl.dart';
import '../domain/repositories/offer_repository.dart';
import '../domain/usecases/create_offer_usecase.dart';
import '../domain/usecases/delete_offer_usecase.dart';
import '../domain/usecases/get_offer_by_id_usecase.dart';
import '../domain/usecases/get_offers_for_date_usecase.dart';
import '../domain/usecases/get_offers_for_range_usecase.dart';
import '../domain/usecases/get_offers_usecase.dart';
import '../domain/usecases/update_offer_usecase.dart';

void registerOffersDependencies(GetIt getIt) {
  getIt.registerLazySingleton<OfferRemoteDataSource>(
    () => OfferRemoteDataSource(getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<OfferRepository>(
    () => OfferRepositoryImpl(getIt<OfferRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetOffersForDateUseCase>(
    () => GetOffersForDateUseCase(getIt<OfferRepository>()),
  );
  getIt.registerLazySingleton<GetOffersForRangeUseCase>(
    () => GetOffersForRangeUseCase(getIt<OfferRepository>()),
  );
  getIt.registerLazySingleton<GetOffersUseCase>(
    () => GetOffersUseCase(getIt<OfferRepository>()),
  );
  getIt.registerLazySingleton<GetOfferByIdUseCase>(
    () => GetOfferByIdUseCase(getIt<OfferRepository>()),
  );
  getIt.registerLazySingleton<CreateOfferUseCase>(
    () => CreateOfferUseCase(getIt<OfferRepository>()),
  );
  getIt.registerLazySingleton<UpdateOfferUseCase>(
    () => UpdateOfferUseCase(getIt<OfferRepository>()),
  );
  getIt.registerLazySingleton<DeleteOfferUseCase>(
    () => DeleteOfferUseCase(getIt<OfferRepository>()),
  );
}
