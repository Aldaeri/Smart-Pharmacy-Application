// providers/user_provider.dart
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final SharedPreferences _prefs;

  UserProvider(this._prefs);

  UserModel? get user => _user;

  Future<void> setUserFromFirestore(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) return;

      QuerySnapshot favoritesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      List<Map<String, dynamic>> favorites = favoritesSnapshot.docs.map((doc) {
        return {
          'medicineId': doc['medicineId'],
          'addedAt': doc['addedAt'],
        };
      }).toList();

      final userData = UserModel.fromMap({
        ...userDoc.data() as Map<String, dynamic>,
        'favorites': favorites,
      });

      await setUser(userData);
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  Future<void> setUser(UserModel user) async {
    _user = user;
    await _prefs.setString('userData', jsonEncode(user.toMap()));
    notifyListeners(); // هذا السطر مهم لتحديث الواجهة
  }

  Future<void> loadUser() async {
    final userDataString = _prefs.getString('userData');
    if (userDataString != null) {
      _user = UserModel.fromMap(jsonDecode(userDataString));
      notifyListeners(); // هذا السطر مهم لتحديث الواجهة
    }
  }

  Future<void> clearUser() async {
    _user = null;
    await _prefs.remove('userData');
    notifyListeners(); // هذا السطر مهم لتحديث الواجهة
  }

  // void setUser(UserModel user) {
  //   _user = user;
  //   notifyListeners();
  // }
  //
  // void clearUser() {
  //   _user = null;
  //   notifyListeners();
  // }
}