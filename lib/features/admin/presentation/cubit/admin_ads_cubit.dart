import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../ads/domain/entities/ad_entity.dart';
import '../../../ads/domain/usecases/create_ad_usecase.dart';
import '../../../ads/domain/usecases/delete_ad_usecase.dart';
import '../../../ads/domain/usecases/get_ads_usecase.dart';
import '../../../ads/domain/usecases/update_ad_usecase.dart';
import 'admin_ads_state.dart';

class AdminAdsCubit extends Cubit<AdminAdsState> {
  AdminAdsCubit({
    required GetAdsUseCase getAds,
    required CreateAdUseCase createAd,
    required UpdateAdUseCase updateAd,
    required DeleteAdUseCase deleteAd,
  }) : _getAds = getAds,
       _createAd = createAd,
       _updateAd = updateAd,
       _deleteAd = deleteAd,
       super(const AdminAdsState());

  final GetAdsUseCase _getAds;
  final CreateAdUseCase _createAd;
  final UpdateAdUseCase _updateAd;
  final DeleteAdUseCase _deleteAd;

  Future<void> load() async {
    if (isClosed) return;
    emit(state.copyWith(status: AdminAdsStatus.loading));
    try {
      final ads = await _getAds();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminAdsStatus.success,
          ads: ads,
          errorMessage: null,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminAdsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> create(AdEntity ad) async {
    try {
      await _createAd(ad);
      if (isClosed) return;
      await load();
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminAdsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> update(AdEntity ad) async {
    try {
      await _updateAd(ad);
      if (isClosed) return;
      await load();
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminAdsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> delete(String id) async {
    try {
      await _deleteAd(id);
      if (isClosed) return;
      await load();
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminAdsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
