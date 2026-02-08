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

  Future<List<OfferModel>> getOffersByRestaurantAndDateRange(
    String restaurantId,
    String startDate,
    String endDate,
  ) async {
    try {
      final snapshot = await firestore
          .collection('offers')
          .where('restaurantId', isEqualTo: restaurantId)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .orderBy('date')
          .orderBy('startTime')
          .get();
      return snapshot.docs.map(OfferModel.fromDoc).toList();
    } catch (_) {
      final fallbackSnapshot = await firestore
          .collection('offers')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();
      final results = fallbackSnapshot.docs
          .map(OfferModel.fromDoc)
          .where((offer) =>
              offer.date.compareTo(startDate) >= 0 &&
              offer.date.compareTo(endDate) <= 0)
          .toList();
      results.sort((a, b) {
        final dateSort = a.date.compareTo(b.date);
        if (dateSort != 0) return dateSort;
        return a.startTime.compareTo(b.startTime);
      });
      return results;
    }
  }

  Future<OfferModel> getOfferById(String id) async {
    final doc = await firestore.collection('offers').doc(id).get();
    return OfferModel.fromDoc(doc);
  }

  Future<List<OfferModel>> getOffers() async {
    final snapshot = await firestore.collection('offers').get();
    return snapshot.docs.map(OfferModel.fromDoc).toList();
  }

  Future<OfferModel> createOffer(OfferModel offer) async {
    final docRef = offer.id.trim().isEmpty
        ? firestore.collection('offers').doc()
        : firestore.collection('offers').doc(offer.id);
    await docRef.set({
      ...offer.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final created = await docRef.get();
    return OfferModel.fromDoc(created);
  }

  Future<OfferModel> updateOffer(OfferModel offer) async {
    final docRef = firestore.collection('offers').doc(offer.id);
    await docRef.set({
      ...offer.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    final updated = await docRef.get();
    return OfferModel.fromDoc(updated);
  }

  Future<void> deleteOffer(String id) async {
    await firestore.collection('offers').doc(id).delete();
  }
}
