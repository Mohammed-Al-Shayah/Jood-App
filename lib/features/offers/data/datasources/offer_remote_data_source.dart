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
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.map(OfferModel.fromDoc).toList();
    }

    final fallbackSnapshot = await firestore
        .collection('offers')
        .where('restaurantId', isEqualTo: restaurantId)
        .get();
    final results = fallbackSnapshot.docs
        .map(OfferModel.fromDoc)
        .where((offer) => offer.date == date)
        .toList();
    results.sort((a, b) => a.startTime.compareTo(b.startTime));
    return results;
  }

  Future<OfferModel> getOfferById(String id) async {
    final doc = await firestore.collection('offers').doc(id).get();
    return OfferModel.fromDoc(doc);
  }
}
