import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // For the timer
import '../providers/cart_provider.dart';
import '../models/product.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Timer? _cartTimer;
  bool _timerStarted = false;

  @override
  void dispose() {
    _cartTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;

    // Start a 1-minute timer when the cart is not empty
    if (cartItems.isNotEmpty && !_timerStarted) {
      _startTimer(cartProvider);
    }

    return Scaffold(
      appBar: AppBar(title: Text("Farmis - Cart")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems.values.toList()[index];
                final Product product = item['product'];
                final int quantity = item['quantity'];

                return Card(
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                        "Price: ₱${product.price} | Quantity: $quantity"),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        cartProvider.removeFromCart(product);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Total: ₱${cartProvider.totalAmount}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: cartItems.isEmpty
                  ? null
                  : () {
                _showCheckoutConfirmationDialog(context, cartProvider);
              },
              child: Text("Checkout"),
            ),
          ),
        ],
      ),
    );
  }

  void _startTimer(CartProvider cartProvider) {
    _timerStarted = true;
    _cartTimer = Timer(Duration(minutes: 1), () {
      cartProvider.restoreCartStock();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cart reached time limit, items reverted to stock")),
      );
    });
  }

// CartScreen.dart

  void _showCheckoutConfirmationDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Checkout"),
        content: Text("Are you sure you want to proceed with the checkout?"),
        actions: [
          TextButton(
            onPressed: () {
              // Cancel checkout, restore stock
              cartProvider.restoreCartStock(); // Restore stock if checkout is canceled
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Checkout canceled, stock restored")),
              );
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              // Proceed with checkout and update stock in the database
              await cartProvider.updateStockOnCheckout(cartProvider.cartItems);
              cartProvider.clearCart(); // Clear the cart after successful checkout
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Checkout complete!")),
              );
            },
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  }

}
