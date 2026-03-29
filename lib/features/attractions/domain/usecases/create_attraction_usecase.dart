import '../entities/attraction_entity.dart';
import '../repositories/attraction_repository.dart';

class CreateAttractionUseCase {
  CreateAttractionUseCase(this.repository);

  final AttractionRepository repository;

  Future<AttractionEntity> call(AttractionEntity attraction) {
    return repository.createAttraction(attraction);
  }
}
