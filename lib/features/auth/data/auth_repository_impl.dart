import '../domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<bool> isSignedIn() async {
    return false;
  }
}
