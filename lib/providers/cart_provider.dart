import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  // Map to store cart items along with the selected quantity
  final Map<int, Map<String, dynamic>> _cartItems = {};

  // Getter to retrieve cart items
  Map<int, Map<String, dynamic>> get cartItems => _cartItems;

  // Add product to cart with quantity (no stock update here)
  // CartProvider.dart

// Add product to cart with quantity (no stock update here)
  void addToCart(Product product, {int quantity = 1}) {
    if (_cartItems.containsKey(product.id)) {
      _cartItems[product.id]!['quantity'] += quantity;  // Increment existing quantity
    } else {
      _cartItems[product.id] = {
        'product': product,
        'quantity': quantity,
      };
    }

    // No stock update here, just adding to the cart
    notifyListeners();
  }


  // Remove product from cart
  void removeFromCart(Product product) {
    if (_cartItems.containsKey(product.id)) {
      final int quantity = _cartItems[product.id]!['quantity'];
      _cartItems.remove(product.id);

      // Optionally, restore stock in the UI (no DB update here)
      notifyListeners();
    }
  }

  // Restore stock if user cancels cart or time expires
  // CartProvider.dart

// Restore stock if user cancels cart or time expires
  void restoreCartStock() {
    _cartItems.forEach((key, value) {
      final Product product = value['product'];
      final int quantity = value['quantity'];

      // Restore stock in the UI (but not in DB here)
      product.stock += quantity;

      // Optionally, update stock in the database if needed
      ApiService.updateProductStock(product.id, product.stock + quantity);
    });

    // Clear the cart after restoring stock
    _cartItems.clear();
    notifyListeners();
  }



  // Update stock in the database only when checkout is confirmed
  // CartProvider.dart

// Update stock in the database only when checkout is confirmed
  Future<void> updateStockOnCheckout(Map<int, Map<String, dynamic>> cartItems) async {
    for (var item in cartItems.values) {
      final Product product = item['product'];
      final int quantity = item['quantity'];
      int updatedStock = product.stock - quantity;

      // Only update stock in the database after confirmation
      await ApiService.updateProductStock(product.id, updatedStock);
    }
  }


  // Clear cart after successful checkout
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Get the total amount of the cart
  double get totalAmount {
    double sum = 0.0;
    _cartItems.forEach((key, value) {
      sum += value['product'].price * value['quantity'];
    });
    return sum;
  }
}
