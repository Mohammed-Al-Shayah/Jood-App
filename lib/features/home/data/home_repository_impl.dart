import '../domain/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<String> loadGreeting() async {
    return 'Welcome to Jood';
  }
}
