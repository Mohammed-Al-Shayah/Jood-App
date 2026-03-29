import '../entities/attraction_entity.dart';

abstract class AttractionRepository {
  Future<List<AttractionEntity>> getAllAttractions();
  Future<AttractionEntity> createAttraction(AttractionEntity attraction);
  Future<AttractionEntity> updateAttraction(AttractionEntity attraction);
  Future<void> deleteAttraction(String id);
}
