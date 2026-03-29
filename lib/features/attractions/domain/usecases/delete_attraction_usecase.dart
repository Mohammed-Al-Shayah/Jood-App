import '../repositories/attraction_repository.dart';

class DeleteAttractionUseCase {
  DeleteAttractionUseCase(this.repository);

  final AttractionRepository repository;

  Future<void> call(String id) {
    return repository.deleteAttraction(id);
  }
}
