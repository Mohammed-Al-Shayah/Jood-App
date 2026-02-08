import 'dart:io';

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
    final ref = storage.ref(
      'restaurants/$safeId/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final task = await ref.putFile(File(file.path));
    return task.ref.getDownloadURL();
  }
}
