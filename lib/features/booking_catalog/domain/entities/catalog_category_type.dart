enum CatalogCategoryType { buffet, setMenu, attraction }

enum CatalogBookingMode { mealBased, timeSlotBased }

extension CatalogCategoryTypeX on CatalogCategoryType {
  String get routeKey {
    switch (this) {
      case CatalogCategoryType.buffet:
        return 'buffet';
      case CatalogCategoryType.setMenu:
        return 'set_menu';
      case CatalogCategoryType.attraction:
        return 'attraction';
    }
  }

  String get title {
    switch (this) {
      case CatalogCategoryType.buffet:
        return 'Buffet';
      case CatalogCategoryType.setMenu:
        return 'Set Menu';
      case CatalogCategoryType.attraction:
        return 'Attractions';
    }
  }

  String get shortDescription {
    switch (this) {
      case CatalogCategoryType.buffet:
        return 'Flexible meal-based bookings with date and guest selection.';
      case CatalogCategoryType.setMenu:
        return 'Fixed set-menu experiences with later item selection support.';
      case CatalogCategoryType.attraction:
        return 'Time-slot packages with dynamic pricing and availability.';
    }
  }

  String get emptyStateTitle {
    switch (this) {
      case CatalogCategoryType.buffet:
        return 'No buffet restaurants available.';
      case CatalogCategoryType.setMenu:
        return 'No set menu restaurants available.';
      case CatalogCategoryType.attraction:
        return 'No attractions available right now.';
    }
  }

  CatalogBookingMode get bookingMode {
    switch (this) {
      case CatalogCategoryType.buffet:
      case CatalogCategoryType.setMenu:
        return CatalogBookingMode.mealBased;
      case CatalogCategoryType.attraction:
        return CatalogBookingMode.timeSlotBased;
    }
  }
}
