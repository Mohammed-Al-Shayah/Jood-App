import 'package:image_picker/image_picker.dart';

import '../repositories/admin_storage_repository.dart';

class UploadRestaurantImageUseCase {
  UploadRestaurantImageUseCase(this.repository);

  final AdminStorageRepository repository;

  Future<String> call({required String restaurantId, required XFile file}) {
    return repository.uploadRestaurantImage(
      restaurantId: restaurantId,
      file: file,
    );
  }
}
