import '../entities/attraction_entity.dart';
import '../repositories/attraction_repository.dart';

class UpdateAttractionUseCase {
  UpdateAttractionUseCase(this.repository);

  final AttractionRepository repository;

  Future<AttractionEntity> call(AttractionEntity attraction) {
    return repository.updateAttraction(attraction);
  }
}
