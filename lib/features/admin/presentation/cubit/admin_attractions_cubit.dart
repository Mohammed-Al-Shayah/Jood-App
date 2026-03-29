import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:jood/features/admin/presentation/cubit/admin_attractions_state.dart';
import 'package:jood/features/attractions/domain/entities/attraction_entity.dart';
import 'package:jood/features/attractions/domain/usecases/create_attraction_usecase.dart';
import 'package:jood/features/attractions/domain/usecases/delete_attraction_usecase.dart';
import 'package:jood/features/attractions/domain/usecases/get_all_attractions_usecase.dart';
import 'package:jood/features/attractions/domain/usecases/update_attraction_usecase.dart';

class AdminAttractionsCubit extends Cubit<AdminAttractionsState> {
  AdminAttractionsCubit({
    required GetAllAttractionsUseCase getAllAttractions,
    required CreateAttractionUseCase createAttraction,
    required UpdateAttractionUseCase updateAttraction,
    required DeleteAttractionUseCase deleteAttraction,
  }) : _getAllAttractions = getAllAttractions,
       _createAttraction = createAttraction,
       _updateAttraction = updateAttraction,
       _deleteAttraction = deleteAttraction,
       super(const AdminAttractionsState());

  final GetAllAttractionsUseCase _getAllAttractions;
  final CreateAttractionUseCase _createAttraction;
  final UpdateAttractionUseCase _updateAttraction;
  final DeleteAttractionUseCase _deleteAttraction;

  Future<void> load() async {
    if (isClosed) return;
    emit(state.copyWith(status: AdminAttractionsStatus.loading));
    try {
      final attractions = await _getAllAttractions();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminAttractionsStatus.success,
          attractions: attractions,
          errorMessage: null,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminAttractionsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> create(AttractionEntity attraction) async {
    try {
      await _createAttraction(attraction);
      if (isClosed) return;
      await load();
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminAttractionsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> update(AttractionEntity attraction) async {
    try {
      await _updateAttraction(attraction);
      if (isClosed) return;
      await load();
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminAttractionsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> delete(String id) async {
    try {
      await _deleteAttraction(id);
      if (isClosed) return;
      await load();
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminAttractionsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
