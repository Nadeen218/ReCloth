import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  // Total count of all pieces in the cart
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + (item['cartQuantity'] as int));

  // Calculate subtotal: (Price * Quantity) for each unique item
  double get subtotal => _cartItems.fold(0, (sum, item) {
    double price = double.tryParse(item['price'].toString()) ?? 0.0;
    int quantity = item['cartQuantity'] ?? 1;
    return sum + (price * quantity);
  });

  // Final total: Subtotal + 5.0 flat shipping fee
  double get total => _cartItems.isEmpty ? 0.0 : subtotal + 5.0;

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Adds item or increments quantity if it already exists
  void addItem(Map<String, dynamic> product) {
    int index = _cartItems.indexWhere((item) =>
    (item['title'] ?? item['name']) == (product['title'] ?? product['name'])
    );

    int maxAvailable = product['quantity'] ?? 1; // Stock from database

    if (index != -1) {
      if (_cartItems[index]['cartQuantity'] < maxAvailable) {
        _cartItems[index]['cartQuantity'] += 1;
        notifyListeners();
      }
    } else {
      _cartItems.add({
        ...product,
        'cartQuantity': 1,
      });
      notifyListeners();
    }
  }

  void incrementQty(int index) {
    int maxAvailable = _cartItems[index]['quantity'] ?? 1;
    if (_cartItems[index]['cartQuantity'] < maxAvailable) {
      _cartItems[index]['cartQuantity'] += 1;
      notifyListeners();
    }
  }

  void decrementQty(int index) {
    if (_cartItems[index]['cartQuantity'] > 1) {
      _cartItems[index]['cartQuantity'] -= 1;
      notifyListeners();
    } else {
      removeItem(index);
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      notifyListeners();
    }
  }
}