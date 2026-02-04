import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/bloc/safe_cubit.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/errors/auth_error_mapper.dart';
import '../../../../../core/utils/auth_validators.dart';
import '../../../../../features/users/domain/usecases/get_user_by_phone_usecase.dart';
import 'forget_password_state.dart';

class ForgetPasswordCubit extends SafeCubit<ForgetPasswordState> {
  ForgetPasswordCubit({
    required FirebaseAuth auth,
    required GetUserByPhoneUseCase getUserByPhone,
  }) : _auth = auth,
       _getUserByPhone = getUserByPhone,
       super(ForgetPasswordState.initial());

  final FirebaseAuth _auth;
  final GetUserByPhoneUseCase _getUserByPhone;

  void updateIdentifier(String value) {
    final input = value.trim();
    final isValid =
        AuthValidators.isEmail(input) || AuthValidators.isPhone(input);
    emitSafe(state.copyWith(input: value, isValid: isValid));
  }

  void updateEmail(String value) => updateIdentifier(value);

  Future<void> submit() async {
    if (!state.isValid || state.status == ForgetPasswordStatus.loading) return;
    emitSafe(
      state.copyWith(
        status: ForgetPasswordStatus.loading,
        errorMessage: null,
        verificationId: null,
        resendToken: null,
      ),
    );
    try {
      final input = state.input.trim();
      if (AuthValidators.isPhone(input)) {
        final normalizedPhone = AuthValidators.normalizePhone(input);
        final user = await _getUserByPhone(normalizedPhone);
        if (user == null) {
          emitSafe(
            state.copyWith(
              status: ForgetPasswordStatus.failure,
              errorMessage: 'No user found for this phone.',
            ),
          );
          return;
        }

        await _auth.verifyPhoneNumber(
          phoneNumber: input,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (_) {},
          verificationFailed: (e) {
            emitSafe(
              state.copyWith(
                status: ForgetPasswordStatus.failure,
                errorMessage: mapFirebaseAuthException(
                  e,
                  operationNotAllowedMessage:
                      'Phone authentication is not enabled for this project.',
                  fallbackMessage: 'Request failed. Please try again.',
                ),
              ),
            );
          },
          codeSent: (verificationId, resendToken) {
            emitSafe(
              state.copyWith(
                status: ForgetPasswordStatus.phoneOtpSent,
                verificationId: verificationId,
                resendToken: resendToken,
              ),
            );
          },
          codeAutoRetrievalTimeout: (_) {},
        );
      } else {
        await _auth.sendPasswordResetEmail(email: input);
        emitSafe(state.copyWith(status: ForgetPasswordStatus.success));
      }
    } on FirebaseAuthException catch (e) {
      emitSafe(
        state.copyWith(
          status: ForgetPasswordStatus.failure,
          errorMessage: mapFirebaseAuthException(
            e,
            operationNotAllowedMessage:
                'Phone authentication is not enabled for this project.',
            fallbackMessage: 'Request failed. Please try again.',
          ),
        ),
      );
    } catch (_) {
      emitSafe(
        state.copyWith(
          status: ForgetPasswordStatus.failure,
          errorMessage: AppStrings.somethingWentWrong,
        ),
      );
    }
  }
}
