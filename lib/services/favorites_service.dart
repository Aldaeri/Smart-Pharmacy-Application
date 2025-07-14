import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Set<String>> getUserFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();

    return snapshot.docs.map((doc) => doc['medicineId'] as String).toSet();
  }

  Future<void> toggleFavorite(String medicineId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final favoritesRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .where('medicineId', isEqualTo: medicineId);

    final existingFavorites = await favoritesRef.get();

    if (existingFavorites.docs.isEmpty) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .add({
        'medicineId': medicineId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } else {
      for (final doc in existingFavorites.docs) {
        await doc.reference.delete();
      }
    }
  }
}