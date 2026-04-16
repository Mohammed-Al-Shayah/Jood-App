import '../../domain/entities/ad_entity.dart';
import '../../domain/repositories/ad_repository.dart';
import '../datasources/ad_remote_data_source.dart';
import '../models/ad_model.dart';

class AdRepositoryImpl implements AdRepository {
  AdRepositoryImpl(this.remoteDataSource);

  final AdRemoteDataSource remoteDataSource;

  @override
  Stream<void> watchAdsChanges() {
    return remoteDataSource.watchAdsChanges();
  }

  @override
  Future<List<AdEntity>> getAds() {
    return remoteDataSource.getAds();
  }

  @override
  Future<List<AdEntity>> getActiveAds() {
    return remoteDataSource.getActiveAds();
  }

  @override
  Future<AdEntity> createAd(AdEntity ad) {
    return remoteDataSource.createAd(ad as AdModel);
  }

  @override
  Future<AdEntity> updateAd(AdEntity ad) {
    return remoteDataSource.updateAd(ad as AdModel);
  }

  @override
  Future<void> deleteAd(String id) {
    return remoteDataSource.deleteAd(id);
  }
}
