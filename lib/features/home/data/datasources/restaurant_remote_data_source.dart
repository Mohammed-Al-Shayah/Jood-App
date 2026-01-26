import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/restaurant_model.dart';

abstract class RestaurantRemoteDataSource {
  Future<List<RestaurantModel>> fetchRestaurants();
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  RestaurantRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<List<RestaurantModel>> fetchRestaurants() async {
    final snapshot = await _firestore.collection('restaurants').get();
    return snapshot.docs
        .map(
          (doc) => RestaurantModel.fromFirestore(
            id: doc.id,
            data: doc.data(),
          ),
        )
        .toList();
  }
}
