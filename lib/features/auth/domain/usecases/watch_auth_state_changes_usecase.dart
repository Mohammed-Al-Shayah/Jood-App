import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class WatchAuthStateChangesUseCase {
  WatchAuthStateChangesUseCase(this._repository);

  final AuthRepository _repository;

  Stream<User?> call() {
    return _repository.authStateChanges();
  }
}
