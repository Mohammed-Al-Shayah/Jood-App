import '../entities/ad_entity.dart';

abstract class AdRepository {
  Stream<void> watchAdsChanges();
  Future<List<AdEntity>> getAds();
  Future<List<AdEntity>> getActiveAds();
  Future<AdEntity> createAd(AdEntity ad);
  Future<AdEntity> updateAd(AdEntity ad);
  Future<void> deleteAd(String id);
}
