import '../../domain/entities/attraction_entity.dart';
import '../../domain/repositories/attraction_repository.dart';
import '../datasources/attraction_remote_data_source.dart';
import '../models/attraction_model.dart';

class AttractionRepositoryImpl implements AttractionRepository {
  AttractionRepositoryImpl(this.remoteDataSource);

  final AttractionRemoteDataSource remoteDataSource;

  @override
  Future<List<AttractionEntity>> getAllAttractions() {
    return remoteDataSource.getAllAttractions();
  }

  @override
  Future<AttractionEntity> createAttraction(AttractionEntity attraction) {
    return remoteDataSource.createAttraction(attraction as AttractionModel);
  }

  @override
  Future<AttractionEntity> updateAttraction(AttractionEntity attraction) {
    return remoteDataSource.updateAttraction(attraction as AttractionModel);
  }

  @override
  Future<void> deleteAttraction(String id) {
    return remoteDataSource.deleteAttraction(id);
  }
}
