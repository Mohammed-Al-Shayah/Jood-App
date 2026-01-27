import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/offer_model.dart';

class OfferRemoteDataSource {
  OfferRemoteDataSource(this.firestore);

  final FirebaseFirestore firestore;

  Future<List<OfferModel>> getOffersByRestaurantAndDate(
    String restaurantId,
    String date,
  ) async {
    final snapshot = await firestore
        .collection('offers')
        .where('restaurantId', isEqualTo: restaurantId)
        .where('date', isEqualTo: date)
        .orderBy('startTime')
        .get();
    return snapshot.docs.map(OfferModel.fromDoc).toList();
  }

  Future<OfferModel> getOfferById(String id) async {
    final doc = await firestore.collection('offers').doc(id).get();
    return OfferModel.fromDoc(doc);
  }
}
