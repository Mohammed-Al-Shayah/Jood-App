import 'package:image_picker/image_picker.dart';
import '../../data/datasources/admin_storage_remote_data_source.dart';

class UploadRestaurantImageUseCase {
  UploadRestaurantImageUseCase(this.remoteDataSource);

  final AdminStorageRemoteDataSource remoteDataSource;

  Future<String> call({
    required String restaurantId,
    required XFile file,
  }) {
    return remoteDataSource.uploadRestaurantImage(
      restaurantId: restaurantId,
      file: file,
    );
  }
}
