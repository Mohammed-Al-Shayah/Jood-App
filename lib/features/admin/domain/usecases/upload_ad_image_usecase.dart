import 'package:image_picker/image_picker.dart';

import '../../data/datasources/admin_storage_remote_data_source.dart';

class UploadAdImageUseCase {
  UploadAdImageUseCase(this.remoteDataSource);

  final AdminStorageRemoteDataSource remoteDataSource;

  Future<String> call({required String adId, required XFile file}) {
    return remoteDataSource.uploadAdImage(adId: adId, file: file);
  }
}
