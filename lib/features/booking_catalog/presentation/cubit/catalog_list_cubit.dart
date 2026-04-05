import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jood/core/localization/app_localization_controller.dart';

import '../../domain/entities/catalog_category_type.dart';
import '../../domain/usecases/get_catalog_items_usecase.dart';
import 'catalog_list_state.dart';

class CatalogListCubit extends Cubit<CatalogListState> {
  CatalogListCubit({required this.getCatalogItems})
    : super(CatalogListState.initial()) {
    AppLocalizationController.instance.localeNotifier.addListener(
      _handleLocaleChanged,
    );
  }

  final GetCatalogItemsUseCase getCatalogItems;

  void _handleLocaleChanged() {
    if (isClosed || state.status == CatalogListStatus.initial) return;
    load(state.category);
  }

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
    } catch (_) {
      emit(
        state.copyWith(
          status: CatalogListStatus.failure,
          category: category,
          items: const [],
          errorMessage: null,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    AppLocalizationController.instance.localeNotifier.removeListener(
      _handleLocaleChanged,
    );
    return super.close();
  }
}
