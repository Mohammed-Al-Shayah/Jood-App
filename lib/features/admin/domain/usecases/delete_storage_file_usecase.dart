import '../../data/datasources/admin_storage_remote_data_source.dart';

class DeleteStorageFileUseCase {
  DeleteStorageFileUseCase(this.remoteDataSource);

  final AdminStorageRemoteDataSource remoteDataSource;

  Future<void> call(String url) {
    return remoteDataSource.deleteByUrl(url);
  }
}
