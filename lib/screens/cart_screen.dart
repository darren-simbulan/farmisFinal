import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/cart_provider.dart';
import '../models/product.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  CartScreenState createState() => CartScreenState();

  // Static method to reset the app start flag
  static void resetAppStartFlag() {
    CartScreenState._appJustStarted = true;
  }
}

class CartScreenState extends State<CartScreen> {
  Timer? _cartTimer;
  bool _timerStarted = false;
  double _userBalance = 1000.0;
  static bool _appJustStarted = true;

  @override
  void initState() {
    super.initState();
    if (_appJustStarted) {
      _userBalance = 1000.0; // Reset to 1000 only on app start
      _appJustStarted = false;
    }
  }

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
          // Display user balance
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Your Balance: ₱$_userBalance",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ),
          Expanded(
            child: cartItems.isEmpty
                ? Center(
              child: Text(
                "Your cart is empty",
                style: TextStyle(fontSize: 18),
              ),
            )
                : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems.values.toList()[index];
                final Product product = item['product'];
                final int quantity = item['quantity'];
                final bool isOutOfStock = product.stock <= 0;

                return Card(
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Price: ₱${product.price} | Quantity: $quantity"),
                        if (isOutOfStock)
                          Text(
                            "OUT OF STOCK",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle,
                          color: isOutOfStock ? Colors.grey : Colors.red),
                      onPressed: isOutOfStock
                          ? null
                          : () {
                        cartProvider.removeFromCart(product);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          if (cartItems.isNotEmpty) ...[
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
                onPressed: _canCheckout(cartProvider)
                    ? () {
                  _showCheckoutConfirmationDialog(context, cartProvider);
                }
                    : null,
                child: Text("Checkout"),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _canCheckout(CartProvider cartProvider) {
    if (cartProvider.cartItems.isEmpty) return false;
    if (cartProvider.totalAmount > _userBalance) return false;

    for (var item in cartProvider.cartItems.values) {
      if (item['product'].stock <= 0) {
        return false;
      }
    }

    return true;
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

  void _showCheckoutConfirmationDialog(BuildContext context, CartProvider cartProvider) {
    final totalAmount = cartProvider.totalAmount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Checkout"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Amount: ₱$totalAmount"),
            Text("Your Balance: ₱$_userBalance"),
            SizedBox(height: 10),
            if (totalAmount > _userBalance)
              Text(
                "Insufficient balance!",
                style: TextStyle(color: Colors.red),
              ),
            Text("Are you sure you want to proceed with the checkout?"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Just close the dialog without doing anything
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: totalAmount > _userBalance
                ? null
                : () async {
              try {
                await cartProvider.updateStockOnCheckout(cartProvider.cartItems);
                setState(() {
                  _userBalance -= totalAmount;
                });
                cartProvider.clearCart();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Checkout complete!")),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Checkout failed: ${e.toString()}")),
                );
              }
            },
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  }
}