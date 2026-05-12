import 'package:get_it/get_it.dart';

import '../../ads/domain/usecases/get_active_ads_usecase.dart';
import '../../ads/domain/usecases/watch_ads_changes_usecase.dart';
import '../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../booking_catalog/domain/usecases/get_catalog_items_usecase.dart';
import '../../booking_catalog/domain/usecases/watch_catalog_changes_usecase.dart';
import '../../users/domain/usecases/get_user_by_id_usecase.dart';
import '../presentation/cubit/home_cubit.dart';

void registerHomeDependencies(GetIt getIt) {
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      getCatalogItems: getIt<GetCatalogItemsUseCase>(),
      watchCatalogChanges: getIt<WatchCatalogChangesUseCase>(),
      getActiveAds: getIt<GetActiveAdsUseCase>(),
      watchAdsChanges: getIt<WatchAdsChangesUseCase>(),
      getUserById: getIt<GetUserByIdUseCase>(),
      getCurrentUser: getIt<GetCurrentUserUseCase>(),
    ),
  );
}
