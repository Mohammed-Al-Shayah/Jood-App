import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  User? call() {
    return _repository.getCurrentUser();
  }
}
