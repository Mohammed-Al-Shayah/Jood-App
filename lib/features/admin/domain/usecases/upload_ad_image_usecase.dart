import 'package:image_picker/image_picker.dart';

import '../repositories/admin_storage_repository.dart';

class UploadAdImageUseCase {
  UploadAdImageUseCase(this.repository);

  final AdminStorageRepository repository;

  Future<String> call({required String adId, required XFile file}) {
    return repository.uploadAdImage(adId: adId, file: file);
  }
}
