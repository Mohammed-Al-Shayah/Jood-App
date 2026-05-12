import 'package:image_picker/image_picker.dart';

abstract class AdminStorageRepository {
  Future<String> uploadRestaurantImage({
    required String restaurantId,
    required XFile file,
  });

  Future<String> uploadAttractionImage({
    required String attractionId,
    required XFile file,
  });

  Future<String> uploadAdImage({required String adId, required XFile file});

  Future<void> deleteByUrl(String url);
}
