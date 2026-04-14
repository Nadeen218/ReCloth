import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  int get itemCount => _cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));

  double get subtotal => _cartItems.fold(0, (sum, item) => sum + item['price'] * item['quantity']);

  double get total => subtotal + 5.0; // 5 shipping

  void addItem(Map<String, dynamic> product) {
    int index = _cartItems.indexWhere((item) => item['name'] == product['name']);
    if (index != -1) {
      _cartItems[index]['quantity']++;
    } else {
      _cartItems.add({...product, 'quantity': 1});
    }
    notifyListeners();
  }

  void removeItem(int index) {
    _cartItems.removeAt(index);
    notifyListeners();
  }

  void increaseQuantity(int index) {
    _cartItems[index]['quantity']++;
    notifyListeners();
  }

  void decreaseQuantity(int index) {
    if (_cartItems[index]['quantity'] > 1) {
      _cartItems[index]['quantity']--;
    } else {
      _cartItems.removeAt(index);
    }
    notifyListeners();
  }
}