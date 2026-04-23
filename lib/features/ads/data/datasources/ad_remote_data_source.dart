import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ad_model.dart';

class AdRemoteDataSource {
  AdRemoteDataSource(this.firestore);

  final FirebaseFirestore firestore;

  Stream<void> watchAdsChanges() {
    return firestore.collection('ads').snapshots().skip(1).map((_) {});
  }

  Future<List<AdModel>> getAds() async {
    final snapshot = await firestore.collection('ads').get();
    final items = snapshot.docs.map(AdModel.fromDoc).toList(growable: false);
    items.sort(_sortAds);
    return items;
  }

  Future<List<AdModel>> getActiveAds() async {
    final snapshot = await firestore
        .collection('ads')
        .where('isActive', isEqualTo: true)
        .get();
    final now = DateTime.now();
    final items = snapshot.docs
        .map(AdModel.fromDoc)
        .where((ad) => ad.canShowOnHomeSliderAt(now))
        .toList(growable: false);
    items.sort(_sortAds);
    return items;
  }

  Future<AdModel> createAd(AdModel ad) async {
    final docRef = ad.id.trim().isEmpty
        ? firestore.collection('ads').doc()
        : firestore.collection('ads').doc(ad.id);
    await docRef.set({
      ...ad.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final created = await docRef.get();
    return AdModel.fromDoc(created);
  }

  Future<AdModel> updateAd(AdModel ad) async {
    final docRef = firestore.collection('ads').doc(ad.id);
    await docRef.set({
      ...ad.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    final updated = await docRef.get();
    return AdModel.fromDoc(updated);
  }

  Future<void> deleteAd(String id) async {
    await firestore.collection('ads').doc(id).delete();
  }

  static int _sortAds(AdModel left, AdModel right) {
    final sortCompare = left.sortOrder.compareTo(right.sortOrder);
    if (sortCompare != 0) return sortCompare;
    return right.updatedAt.compareTo(left.updatedAt);
  }
}
