import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../users/domain/usecases/get_user_by_email_usecase.dart';
import '../../users/domain/usecases/get_user_by_phone_usecase.dart';
import '../../users/domain/usecases/sync_auth_user_usecase.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/check_email_in_use_usecase.dart';
import '../domain/usecases/delete_account_usecase.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/link_email_password_usecase.dart';
import '../domain/usecases/login_with_email_usecase.dart';
import '../domain/usecases/reload_user_usecase.dart';
import '../domain/usecases/send_email_verification_usecase.dart';
import '../domain/usecases/send_password_reset_email_usecase.dart';
import '../domain/usecases/send_phone_otp_usecase.dart';
import '../domain/usecases/sign_out_usecase.dart';
import '../domain/usecases/update_password_usecase.dart';
import '../domain/usecases/verify_before_update_email_usecase.dart';
import '../domain/usecases/verify_otp_usecase.dart';
import '../domain/usecases/watch_auth_state_changes_usecase.dart';
import '../presentation/change_password/logic/change_password_cubit.dart';
import '../presentation/forget_password/logic/forget_password_cubit.dart';
import '../presentation/login/logic/login_cubit.dart';
import '../presentation/registration/logic/register_cubit.dart';

void registerAuthDependencies(GetIt getIt) {
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<FirebaseAuth>(), getIt()),
  );
  getIt.registerLazySingleton<LoginWithEmailUseCase>(
    () => LoginWithEmailUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<CheckEmailInUseUseCase>(
    () => CheckEmailInUseUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<SendPhoneOtpUseCase>(
    () => SendPhoneOtpUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<VerifyOtpUseCase>(
    () => VerifyOtpUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<SendPasswordResetEmailUseCase>(
    () => SendPasswordResetEmailUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<SendEmailVerificationUseCase>(
    () => SendEmailVerificationUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<WatchAuthStateChangesUseCase>(
    () => WatchAuthStateChangesUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<DeleteAccountUseCase>(
    () => DeleteAccountUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<ReloadUserUseCase>(
    () => ReloadUserUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<LinkEmailPasswordUseCase>(
    () => LinkEmailPasswordUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<UpdatePasswordUseCase>(
    () => UpdatePasswordUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<VerifyBeforeUpdateEmailUseCase>(
    () => VerifyBeforeUpdateEmailUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(
      loginWithEmail: getIt<LoginWithEmailUseCase>(),
      sendEmailVerification: getIt<SendEmailVerificationUseCase>(),
      signOut: getIt<SignOutUseCase>(),
      getCurrentUser: getIt<GetCurrentUserUseCase>(),
      reloadUser: getIt<ReloadUserUseCase>(),
      getUserByPhone: getIt<GetUserByPhoneUseCase>(),
      syncAuthUser: getIt<SyncAuthUserUseCase>(),
    ),
  );
  getIt.registerFactory<ForgetPasswordCubit>(
    () => ForgetPasswordCubit(
      sendPhoneOtp: getIt<SendPhoneOtpUseCase>(),
      sendPasswordResetEmail: getIt<SendPasswordResetEmailUseCase>(),
      getUserByPhone: getIt<GetUserByPhoneUseCase>(),
    ),
  );
  getIt.registerFactory<ChangePasswordCubit>(
    () => ChangePasswordCubit(
      getCurrentUser: getIt<GetCurrentUserUseCase>(),
      updatePassword: getIt<UpdatePasswordUseCase>(),
      signOut: getIt<SignOutUseCase>(),
    ),
  );
  getIt.registerFactory<RegisterCubit>(
    () => RegisterCubit(
      checkEmailInUse: getIt<CheckEmailInUseUseCase>(),
      sendPhoneOtp: getIt<SendPhoneOtpUseCase>(),
      getUserByEmail: getIt<GetUserByEmailUseCase>(),
      getUserByPhone: getIt<GetUserByPhoneUseCase>(),
    ),
  );
}
