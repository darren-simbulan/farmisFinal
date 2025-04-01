import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class PurchaseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Confirm Purchase")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Total Amount: ₱${cart.totalAmount}", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                cart.cartItems.clear(); // I-clear ang cart pagkatapos ng purchase
                cart.notifyListeners(); // Notify UI update

                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Purchase Successful!"))
                );
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text("Confirm Purchase"),
            ),
          ],
        ),
      ),
    );
  }
}
