import 'package:image_picker/image_picker.dart';

import '../../domain/repositories/admin_storage_repository.dart';
import '../datasources/admin_storage_remote_data_source.dart';

class AdminStorageRepositoryImpl implements AdminStorageRepository {
  AdminStorageRepositoryImpl(this.remoteDataSource);

  final AdminStorageRemoteDataSource remoteDataSource;

  @override
  Future<String> uploadRestaurantImage({
    required String restaurantId,
    required XFile file,
  }) {
    return remoteDataSource.uploadRestaurantImage(
      restaurantId: restaurantId,
      file: file,
    );
  }

  @override
  Future<String> uploadAttractionImage({
    required String attractionId,
    required XFile file,
  }) {
    return remoteDataSource.uploadAttractionImage(
      attractionId: attractionId,
      file: file,
    );
  }

  @override
  Future<String> uploadAdImage({required String adId, required XFile file}) {
    return remoteDataSource.uploadAdImage(adId: adId, file: file);
  }

  @override
  Future<void> deleteByUrl(String url) {
    return remoteDataSource.deleteByUrl(url);
  }
}
