import '../entities/attraction_entity.dart';
import '../repositories/attraction_repository.dart';

class GetAllAttractionsUseCase {
  GetAllAttractionsUseCase(this.repository);

  final AttractionRepository repository;

  Future<List<AttractionEntity>> call() {
    return repository.getAllAttractions();
  }
}
