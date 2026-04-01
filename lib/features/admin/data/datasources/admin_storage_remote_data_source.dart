import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AdminStorageRemoteDataSource {
  AdminStorageRemoteDataSource(this.storage);

  final FirebaseStorage storage;

  Future<String> uploadRestaurantImage({
    required String restaurantId,
    required XFile file,
  }) async {
    final safeId = restaurantId.trim().isEmpty ? 'new' : restaurantId.trim();
    final bytes = await file.readAsBytes();
    final ref = storage.ref(
      'restaurants/$safeId/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final task = await ref.putData(
      bytes,
      SettableMetadata(contentType: file.mimeType ?? 'image/jpeg'),
    );
    return task.ref.getDownloadURL();
  }

  Future<String> uploadAttractionImage({
    required String attractionId,
    required XFile file,
  }) async {
    final safeId = attractionId.trim().isEmpty ? 'new' : attractionId.trim();
    final bytes = await file.readAsBytes();
    final ref = storage.ref(
      'attractions/$safeId/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final task = await ref.putData(
      bytes,
      SettableMetadata(contentType: file.mimeType ?? 'image/jpeg'),
    );
    return task.ref.getDownloadURL();
  }

  Future<void> deleteByUrl(String url) async {
    if (url.trim().isEmpty) return;
    final ref = storage.refFromURL(url);
    await ref.delete();
  }
}
