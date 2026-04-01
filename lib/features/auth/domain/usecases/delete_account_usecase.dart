import '../repositories/auth_repository.dart';

class DeleteAccountUseCase {
  DeleteAccountUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() {
    return _repository.deleteAccount();
  }
}
