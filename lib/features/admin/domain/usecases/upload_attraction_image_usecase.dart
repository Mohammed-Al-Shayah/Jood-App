import 'package:image_picker/image_picker.dart';

import '../repositories/admin_storage_repository.dart';

class UploadAttractionImageUseCase {
  UploadAttractionImageUseCase(this.repository);

  final AdminStorageRepository repository;

  Future<String> call({required String attractionId, required XFile file}) {
    return repository.uploadAttractionImage(
      attractionId: attractionId,
      file: file,
    );
  }
}
