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

  Future<RestaurantModel> getRestaurantById(String id) async {
    final doc = await firestore.collection('restaurants').doc(id).get();
    return RestaurantModel.fromDoc(doc);
  }
}
