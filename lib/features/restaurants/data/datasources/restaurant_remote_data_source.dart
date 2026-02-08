import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/restaurant_model.dart';

class RestaurantRemoteDataSource {
  RestaurantRemoteDataSource(this.firestore);

  final FirebaseFirestore firestore;

  Future<List<RestaurantModel>> getRestaurants() async {
    final snapshot = await firestore
        .collection('restaurants')
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs.map(RestaurantModel.fromDoc).toList();
  }

  Future<List<RestaurantModel>> getAllRestaurants() async {
    final snapshot = await firestore.collection('restaurants').get();
    return snapshot.docs.map(RestaurantModel.fromDoc).toList();
  }

  Future<RestaurantModel> getRestaurantById(String id) async {
    final doc = await firestore.collection('restaurants').doc(id).get();
    return RestaurantModel.fromDoc(doc);
  }

  Future<RestaurantModel> createRestaurant(RestaurantModel restaurant) async {
    final docRef = restaurant.id.trim().isEmpty
        ? firestore.collection('restaurants').doc()
        : firestore.collection('restaurants').doc(restaurant.id);
    await docRef.set({
      ...restaurant.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final created = await docRef.get();
    return RestaurantModel.fromDoc(created);
  }

  Future<RestaurantModel> updateRestaurant(RestaurantModel restaurant) async {
    final docRef = firestore.collection('restaurants').doc(restaurant.id);
    await docRef.set({
      ...restaurant.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    final updated = await docRef.get();
    return RestaurantModel.fromDoc(updated);
  }

  Future<void> deleteRestaurant(String id) async {
    await firestore.collection('restaurants').doc(id).delete();
  }
}
