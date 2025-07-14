import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/medicine_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalItems => _items.fold(0, (sum, item) => sum + (item.quantity));

  double get totalAmount =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addToCart(Medicine medicine) {
    final existingIndex = _items.indexWhere(
      (item) => item.medicine.id == medicine.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(medicine: medicine));
    }
    notifyListeners();
  }

  void removeFromCart(String medicineId) {
    final existingIndex = _items.indexWhere(
      (item) => item.medicine.id == medicineId,
    );
    if (existingIndex >= 0) {
      _items.removeAt(existingIndex);
      notifyListeners();
    }
  }

  void decreaseQuantity(String medicineId) {
    final existingIndex = _items.indexWhere(
      (item) => item.medicine.id == medicineId,
    );
    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity > 1) {
        _items[existingIndex].quantity--;
      } else {
        _items.removeAt(existingIndex);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // final List<CartItem> _items = [];
  // List<CartItem> get items => _items;
  // int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  // double get totalAmount => _items.fold(0, (sum, item) => sum + item.totalPrice);

  // void addItem(Medicine medicine) {
  //   final existingIndex = _items.indexWhere((item) => item.medicine.id == medicine.id);
  //
  //   if (existingIndex >= 0) {
  //     _items[existingIndex].quantity++;
  //   } else {
  //     _items.add(CartItem(medicine: medicine));
  //   }
  //   notifyListeners();
  // }

  // void removeItem(String medicineId) {
  //   final existingIndex = _items.indexWhere((item) => item.medicine.id == medicineId);
  //   if (existingIndex >= 0) {
  //     _items.removeAt(existingIndex);
  //     notifyListeners();
  //   }
  // }

  // void decreaseQuantity(String medicineId) {
  //   final existingIndex = _items.indexWhere((item) => item.medicine.id == medicineId);
  //   if (existingIndex >= 0) {
  //     if (_items[existingIndex].quantity > 1) {
  //       _items[existingIndex].quantity--;
  //     } else {
  //       _items.removeAt(existingIndex);
  //     }
  //     notifyListeners();
  //   }
  // }

  // void clearCart() {
  //   _items.clear();
  //   notifyListeners();
  // }
}
