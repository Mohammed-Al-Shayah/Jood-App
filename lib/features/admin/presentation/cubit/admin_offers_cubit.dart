import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../offers/domain/entities/offer_entity.dart';
import '../../../offers/domain/usecases/create_offer_usecase.dart';
import '../../../offers/domain/usecases/delete_offer_usecase.dart';
import '../../../offers/domain/usecases/get_offers_usecase.dart';
import '../../../offers/domain/usecases/update_offer_usecase.dart';
import 'admin_offers_state.dart';

class AdminOffersCubit extends Cubit<AdminOffersState> {
  AdminOffersCubit({
    required GetOffersUseCase getOffers,
    required CreateOfferUseCase createOffer,
    required UpdateOfferUseCase updateOffer,
    required DeleteOfferUseCase deleteOffer,
  }) : _getOffers = getOffers,
       _createOffer = createOffer,
       _updateOffer = updateOffer,
       _deleteOffer = deleteOffer,
       super(const AdminOffersState());

  final GetOffersUseCase _getOffers;
  final CreateOfferUseCase _createOffer;
  final UpdateOfferUseCase _updateOffer;
  final DeleteOfferUseCase _deleteOffer;

  Future<void> load() async {
    if (isClosed) return;
    emit(state.copyWith(status: AdminOffersStatus.loading));
    try {
      final offers = await _getOffers();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminOffersStatus.success,
          offers: offers,
          errorMessage: null,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminOffersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> create(OfferEntity offer) async {
    try {
      await _createOffer(offer);
      if (isClosed) return;
      await load();
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminOffersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> createMany(List<OfferEntity> offers) async {
    if (offers.isEmpty) return;
    try {
      await _createOffer.many(offers);
      if (isClosed) return;
      await load();
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminOffersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> update(OfferEntity offer) async {
    try {
      await _updateOffer(offer);
      if (isClosed) return;
      await load();
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminOffersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> delete(String id) async {
    try {
      await _deleteOffer(id);
      if (isClosed) return;
      await load();
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminOffersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> deleteMany(List<String> ids) async {
    if (ids.isEmpty) return;
    try {
      for (final id in ids) {
        await _deleteOffer(id);
        if (isClosed) return;
      }
      if (isClosed) return;
      await load();
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminOffersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
