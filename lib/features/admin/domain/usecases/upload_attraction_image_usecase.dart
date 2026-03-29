import 'package:image_picker/image_picker.dart';

import '../../data/datasources/admin_storage_remote_data_source.dart';

class UploadAttractionImageUseCase {
  UploadAttractionImageUseCase(this.remoteDataSource);

  final AdminStorageRemoteDataSource remoteDataSource;

  Future<String> call({required String attractionId, required XFile file}) {
    return remoteDataSource.uploadAttractionImage(
      attractionId: attractionId,
      file: file,
    );
  }
}
