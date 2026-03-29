import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/attraction_model.dart';

class AttractionRemoteDataSource {
  AttractionRemoteDataSource(this.firestore);

  final FirebaseFirestore firestore;

  Future<List<AttractionModel>> getAllAttractions() async {
    final snapshot = await firestore.collection('attractions').get();
    return snapshot.docs.map(AttractionModel.fromDoc).toList(growable: false);
  }

  Future<AttractionModel> createAttraction(AttractionModel attraction) async {
    final docRef = attraction.id.trim().isEmpty
        ? firestore.collection('attractions').doc()
        : firestore.collection('attractions').doc(attraction.id);
    await docRef.set({
      ...attraction.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final created = await docRef.get();
    return AttractionModel.fromDoc(created);
  }

  Future<AttractionModel> updateAttraction(AttractionModel attraction) async {
    final docRef = firestore.collection('attractions').doc(attraction.id);
    await docRef.set({
      ...attraction.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    final updated = await docRef.get();
    return AttractionModel.fromDoc(updated);
  }

  Future<void> deleteAttraction(String id) async {
    final offersSnapshot = await firestore
        .collection('offers')
        .where('restaurantId', isEqualTo: id)
        .get();
    final batch = firestore.batch();
    for (final doc in offersSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(firestore.collection('attractions').doc(id));
    await batch.commit();
  }
}
