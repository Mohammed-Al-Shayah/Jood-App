import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../../core/payments/payment_completion_service.dart';
import '../../bookings/domain/usecases/create_booking_usecase.dart';
import '../data/datasources/payment_remote_data_source.dart';
import '../data/repositories/payment_repository_impl.dart';
import '../domain/repositories/payment_repository.dart';
import '../domain/usecases/create_payment_usecase.dart';
import '../domain/usecases/get_payment_by_booking_usecase.dart';

void registerPaymentsDependencies(GetIt getIt) {
  getIt.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSource(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(
      remoteDataSource: getIt<PaymentRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<GetPaymentByBookingUseCase>(
    () => GetPaymentByBookingUseCase(getIt<PaymentRepository>()),
  );
  getIt.registerLazySingleton<CreatePaymentUseCase>(
    () => CreatePaymentUseCase(getIt<PaymentRepository>()),
  );
  getIt.registerLazySingleton<PaymentCompletionService>(
    () => PaymentCompletionService(
      createBooking: getIt<CreateBookingUseCase>(),
      createPayment: getIt<CreatePaymentUseCase>(),
    ),
  );
}
