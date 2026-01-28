import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserRemoteDataSource {
  UserRemoteDataSource({required this.firestore});

  final FirebaseFirestore firestore;

  Future<UserModel?> getUserById(String id) async {
    final doc = await firestore.collection('users').doc(id).get();
    final data = doc.data();
    if (data == null) return null;
    return UserModel.fromMap(doc.id, data);
  }

  Future<void> createUser(UserModel user) {
    return firestore.collection('users').doc(user.id).set(
          user.toMap(),
          SetOptions(merge: true),
        );
  }
}
