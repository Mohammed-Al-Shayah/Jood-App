import 'package:equatable/equatable.dart';

import '../../../ads/domain/entities/ad_entity.dart';
import '../../../booking_catalog/domain/entities/catalog_category_type.dart';
import '../../../booking_catalog/domain/entities/catalog_item_entity.dart';

enum HomeStatus { initial, loading, success, empty, failure }

enum SortField { price, discount, rating }

enum SortOrder { asc, desc }

class HomeState extends Equatable {
  static const Object _unset = Object();

  const HomeState({
    this.status = HomeStatus.initial,
    this.items = const [],
    this.filteredItems = const [],
    this.ads = const [],
    this.query = '',
    this.selectedCategory,
    this.sortField,
    this.sortOrder = SortOrder.desc,
    this.errorMessage,
    this.userCity,
    this.userCountry,
  });

  final HomeStatus status;
  final List<CatalogItemEntity> items;
  final List<CatalogItemEntity> filteredItems;
  final List<AdEntity> ads;
  final String query;
  final CatalogCategoryType? selectedCategory;
  final SortField? sortField;
  final SortOrder sortOrder;
  final String? errorMessage;
  final String? userCity;
  final String? userCountry;

  HomeState copyWith({
    HomeStatus? status,
    List<CatalogItemEntity>? items,
    List<CatalogItemEntity>? filteredItems,
    List<AdEntity>? ads,
    String? query,
    Object? selectedCategory = _unset,
    Object? sortField = _unset,
    SortOrder? sortOrder,
    Object? errorMessage = _unset,
    String? userCity,
    String? userCountry,
  }) {
    return HomeState(
      status: status ?? this.status,
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      ads: ads ?? this.ads,
      query: query ?? this.query,
      selectedCategory: identical(selectedCategory, _unset)
          ? this.selectedCategory
          : selectedCategory as CatalogCategoryType?,
      sortField: identical(sortField, _unset)
          ? this.sortField
          : sortField as SortField?,
      sortOrder: sortOrder ?? this.sortOrder,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      userCity: userCity ?? this.userCity,
      userCountry: userCountry ?? this.userCountry,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    filteredItems,
    ads,
    query,
    selectedCategory,
    sortField,
    sortOrder,
    errorMessage,
    userCity,
    userCountry,
  ];
}
