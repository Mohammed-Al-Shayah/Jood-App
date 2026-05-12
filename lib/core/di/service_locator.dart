import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/admin/di/admin_di.dart';
import '../../features/ads/di/ads_di.dart';
import '../../features/attractions/di/attractions_di.dart';
import '../../features/auth/di/auth_di.dart';
import '../../features/booking_catalog/di/booking_catalog_di.dart';
import '../../features/bookings/di/bookings_di.dart';
import '../../features/home/di/home_di.dart';
import '../../features/offers/di/offers_di.dart';
import '../../features/payments/di/payments_di.dart';
import '../../features/restaurants/di/restaurants_di.dart';
import '../../features/users/di/users_di.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  _registerCoreDependencies(getIt);
  registerAdsDependencies(getIt);
  registerBookingCatalogDependencies(getIt);
  registerOffersDependencies(getIt);
  registerAuthDependencies(getIt);
  registerUsersDependencies(getIt);
  registerPaymentsDependencies(getIt);
  registerBookingsDependencies(getIt);
  registerRestaurantsDependencies(getIt);
  registerAttractionsDependencies(getIt);
  registerHomeDependencies(getIt);
  registerAdminDependencies(getIt);
}

void _registerCoreDependencies(GetIt getIt) {
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFunctions>(
    () => FirebaseFunctions.instance,
  );
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
}
