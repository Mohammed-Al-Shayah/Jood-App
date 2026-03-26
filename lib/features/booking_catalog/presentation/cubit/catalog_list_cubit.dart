import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/catalog_category_type.dart';
import '../../domain/usecases/get_catalog_items_usecase.dart';
import 'catalog_list_state.dart';

class CatalogListCubit extends Cubit<CatalogListState> {
  CatalogListCubit({required this.getCatalogItems})
    : super(CatalogListState.initial());

  final GetCatalogItemsUseCase getCatalogItems;

  Future<void> load(CatalogCategoryType category) async {
    emit(
      state.copyWith(
        status: CatalogListStatus.loading,
        category: category,
        items: const [],
        errorMessage: null,
      ),
    );
    try {
      final items = await getCatalogItems(category);
      emit(
        state.copyWith(
          status: CatalogListStatus.success,
          category: category,
          items: items,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CatalogListStatus.failure,
          category: category,
          items: const [],
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
