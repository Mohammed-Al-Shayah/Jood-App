part of 'admin_offer_form_content_impl.dart';

class _AttractionPackageDraft {
  _AttractionPackageDraft({
    required String packageName,
    required String packageNameAr,
    required String packageDescription,
    required String packageDescriptionAr,
    required String priceAdult,
    required String priceAdultOriginal,
    required String priceChild,
    required String capacityAdult,
    required String capacityChild,
    required String bookedAdult,
    required String bookedChild,
    required this.status,
    required String entryConditions,
    required String entryConditionsAr,
  }) : packageNameController = TextEditingController(text: packageName),
       packageNameArController = TextEditingController(text: packageNameAr),
       packageDescriptionController = TextEditingController(
         text: packageDescription,
       ),
       packageDescriptionArController = TextEditingController(
         text: packageDescriptionAr,
       ),
       priceAdultController = TextEditingController(text: priceAdult),
       priceAdultOriginalController = TextEditingController(
         text: priceAdultOriginal,
       ),
       priceChildController = TextEditingController(text: priceChild),
       capacityAdultController = TextEditingController(text: capacityAdult),
       capacityChildController = TextEditingController(text: capacityChild),
       bookedAdultController = TextEditingController(text: bookedAdult),
       bookedChildController = TextEditingController(text: bookedChild),
       entryConditionsController = TextEditingController(text: entryConditions),
       entryConditionsArController = TextEditingController(
         text: entryConditionsAr,
       );

  final TextEditingController packageNameController;
  final TextEditingController packageNameArController;
  final TextEditingController packageDescriptionController;
  final TextEditingController packageDescriptionArController;
  final TextEditingController priceAdultController;
  final TextEditingController priceAdultOriginalController;
  final TextEditingController priceChildController;
  final TextEditingController capacityAdultController;
  final TextEditingController capacityChildController;
  final TextEditingController bookedAdultController;
  final TextEditingController bookedChildController;
  final TextEditingController entryConditionsController;
  final TextEditingController entryConditionsArController;
  String status;

  List<String> entryConditions() {
    return _splitLines(entryConditionsController.text);
  }

  List<String> entryConditionsAr() {
    return _splitLines(entryConditionsArController.text);
  }

  static List<String> _splitLines(String value) {
    return value
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  void dispose() {
    packageNameController.dispose();
    packageNameArController.dispose();
    packageDescriptionController.dispose();
    packageDescriptionArController.dispose();
    priceAdultController.dispose();
    priceAdultOriginalController.dispose();
    priceChildController.dispose();
    capacityAdultController.dispose();
    capacityChildController.dispose();
    bookedAdultController.dispose();
    bookedChildController.dispose();
    entryConditionsController.dispose();
    entryConditionsArController.dispose();
  }
}

class _VenueOption {
  const _VenueOption({required this.id, required this.name});

  final String id;
  final String name;
}

class _RestaurantCategorySupport {
  const _RestaurantCategorySupport({
    required this.name,
    required this.supportsBuffet,
    required this.supportsSetMenu,
    required this.supportsCombo,
  });

  final String name;
  final bool supportsBuffet;
  final bool supportsSetMenu;
  final bool supportsCombo;
}
