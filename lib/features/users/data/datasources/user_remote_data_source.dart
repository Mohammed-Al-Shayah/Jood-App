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

  Future<UserModel?> getUserByPhone(String phone) async {
    final normalized = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final byNormalized = await firestore
        .collection('users')
        .where('phoneNormalized', isEqualTo: normalized)
        .limit(1)
        .get();
    if (byNormalized.docs.isNotEmpty) {
      final doc = byNormalized.docs.first;
      return UserModel.fromMap(doc.id, doc.data());
    }
    final query = await firestore
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    return UserModel.fromMap(doc.id, doc.data());
  }

  Future<void> createUser(UserModel user) {
    return firestore.collection('users').doc(user.id).set(
          user.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<void> updateUser(UserModel user) {
    return firestore.collection('users').doc(user.id).set(
          user.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<List<UserModel>> getUsers() async {
    final snapshot = await firestore.collection('users').get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.id, doc.data())).toList();
  }

  Future<void> deleteUser(String id) {
    return firestore.collection('users').doc(id).delete();
  }
}
