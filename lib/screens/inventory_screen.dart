import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void fetchProducts() async {
    products = await ApiService.getProducts();
    setState(() {});
  }

  void deleteProduct(int id) async {
    await ApiService.deleteProduct(id);
    fetchProducts();
  }

  void showAddProductDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController stockController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Product Name"),
            ),
            TextField(
              controller: stockController,
              decoration: InputDecoration(labelText: "Stock"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              String name = nameController.text.trim();
              int stock = int.tryParse(stockController.text.trim()) ?? 0;
              double price = double.tryParse(priceController.text.trim()) ?? 0.0;

              if (name.isEmpty || stock <= 0 || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Invalid input!")));
                return;
              }

              await ApiService.addProduct(Product(id: 0, name: name, stock: stock, price: price));
              fetchProducts();
              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  void updateProductStock(int productId, int newStock) async {
    Product updatedProduct = products.firstWhere((product) => product.id == productId);
    updatedProduct.stock = newStock;

    await ApiService.updateProduct(updatedProduct);
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Farmis - Inventory")),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            child: ListTile(
              title: Text(product.name),
              subtitle: Text("Stock: ${product.stock} | Price: ₱${product.price}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.add_shopping_cart, color: Colors.green),
                    onPressed: () {
                      cartProvider.addToCart(product);
                      int newStock = product.stock - 1; // Reduce stock by 1 when added to cart
                      updateProductStock(product.id, newStock);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${product.name} added to cart!"))
                      );
                    },
                  ),
                  // IconButton(
                  //   icon: Icon(Icons.delete, color: Colors.red),
                  //   onPressed: () => deleteProduct(product.id),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddProductDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
