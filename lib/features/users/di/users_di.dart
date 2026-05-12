import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../auth/domain/usecases/delete_account_usecase.dart';
import '../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../auth/domain/usecases/reload_user_usecase.dart';
import '../../auth/domain/usecases/sign_out_usecase.dart';
import '../data/datasources/user_remote_data_source.dart';
import '../data/repositories/user_repository_impl.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/usecases/create_user_usecase.dart';
import '../domain/usecases/delete_user_usecase.dart';
import '../domain/usecases/get_user_by_email_usecase.dart';
import '../domain/usecases/get_user_by_id_usecase.dart';
import '../domain/usecases/get_user_by_phone_usecase.dart';
import '../domain/usecases/get_users_usecase.dart';
import '../domain/usecases/sync_auth_user_usecase.dart';
import '../domain/usecases/update_user_usecase.dart';
import '../presentation/cubit/profile_cubit.dart';

void registerUsersDependencies(GetIt getIt) {
  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: getIt<UserRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetUserByIdUseCase>(
    () => GetUserByIdUseCase(getIt<UserRepository>()),
  );
  getIt.registerLazySingleton<GetUserByEmailUseCase>(
    () => GetUserByEmailUseCase(getIt<UserRepository>()),
  );
  getIt.registerLazySingleton<GetUserByPhoneUseCase>(
    () => GetUserByPhoneUseCase(getIt<UserRepository>()),
  );
  getIt.registerLazySingleton<CreateUserUseCase>(
    () => CreateUserUseCase(getIt<UserRepository>()),
  );
  getIt.registerLazySingleton<UpdateUserUseCase>(
    () => UpdateUserUseCase(getIt<UserRepository>()),
  );
  getIt.registerLazySingleton<GetUsersUseCase>(
    () => GetUsersUseCase(getIt<UserRepository>()),
  );
  getIt.registerLazySingleton<DeleteUserUseCase>(
    () => DeleteUserUseCase(getIt<UserRepository>()),
  );
  getIt.registerLazySingleton<SyncAuthUserUseCase>(
    () => SyncAuthUserUseCase(
      getUserById: getIt<GetUserByIdUseCase>(),
      createUser: getIt<CreateUserUseCase>(),
      updateUser: getIt<UpdateUserUseCase>(),
    ),
  );
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      getUserById: getIt<GetUserByIdUseCase>(),
      updateUser: getIt<UpdateUserUseCase>(),
      getCurrentUser: getIt<GetCurrentUserUseCase>(),
      reloadUser: getIt<ReloadUserUseCase>(),
      signOut: getIt<SignOutUseCase>(),
      deleteAccount: getIt<DeleteAccountUseCase>(),
    ),
  );
}
