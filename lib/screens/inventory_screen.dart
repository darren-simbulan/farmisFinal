import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  InventoryScreenState createState() => InventoryScreenState();
}

class InventoryScreenState extends State<InventoryScreen> {
  List<Product> products = [];
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void fetchProducts() async {
    products = await ApiService.getProducts();
    setState(() {});
  }

  void _showAuthDialog() {
    _emailController.clear();
    _passwordController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Admin Login"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_emailController.text == "admin" &&
                  _passwordController.text == "admin") {
                setState(() {
                  isAdmin = true;
                });
                Navigator.of(context).pop();
                _showActionChoiceDialog();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Invalid credentials")),
                );
              }
            },
            child: Text("Login"),
          ),
        ],
      ),
    );
  }

  void _showActionChoiceDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text("Admin Actions"),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              showAddProductDialog();
            },
            child: Text("Create New Product"),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              showProductSelectionDialog("update");
            },
            child: Text("Update Existing Product"),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              showProductSelectionDialog("delete");
            },
            child: Text("Delete Product", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void showProductSelectionDialog(String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action == "update" ? "Select Product to Update" : "Select Product to Delete"),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product.name),
                onTap: () {
                  Navigator.of(context).pop();
                  if (action == "update") {
                    _showEditProductDialog(product);
                  } else {
                    _confirmDelete(product.id, product.name);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showActionChoiceDialog();
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void showAddProductDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController stockController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Product"),
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
            onPressed: () {
              Navigator.of(context).pop();
              _showActionChoiceDialog();
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              String name = nameController.text.trim();
              int stock = int.tryParse(stockController.text.trim()) ?? 0;
              double price = double.tryParse(priceController.text.trim()) ?? 0.0;

              if (name.isEmpty || stock <= 0 || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Invalid input!")),
                );
                return;
              }

              await ApiService.addProduct(Product(id: 0, name: name, stock: stock, price: price));
              fetchProducts();
              Navigator.of(context).pop();
            },
            child: Text("Add Product"),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(Product product) {
    TextEditingController nameController = TextEditingController(text: product.name);
    TextEditingController stockController = TextEditingController(text: product.stock.toString());
    TextEditingController priceController = TextEditingController(text: product.price.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Update Product"),
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
            onPressed: () {
              Navigator.of(context).pop(); // Close the current dialog
              showProductSelectionDialog("update"); // Go back to product selection
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              String name = nameController.text.trim();
              int stock = int.tryParse(stockController.text.trim()) ?? 0;
              double price = double.tryParse(priceController.text.trim()) ?? 0.0;

              if (name.isEmpty || stock < 0 || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Invalid input!")),
                );
                return;
              }

              Product updatedProduct = Product(
                id: product.id,
                name: name,
                stock: stock,
                price: price,
              );

              await ApiService.updateProduct(updatedProduct);
              fetchProducts();
              Navigator.of(context).pop();
            },
            child: Text("Update Product"),
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

  void _confirmDelete(int productId, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete $productName?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              showProductSelectionDialog("delete");
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the confirmation dialog
              try {
                await ApiService.deleteProduct(productId);
                fetchProducts();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$productName deleted successfully")),
                );
                // Show the product selection dialog again after deletion
                showProductSelectionDialog("delete");
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to delete: ${e.toString()}")),
                );
                // Show the product selection dialog again even if deletion fails
                showProductSelectionDialog("delete");
              }
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
          final bool isOutOfStock = product.stock <= 0;

          return Card(
            child: ListTile(
              title: Text(product.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Price: ₱${product.price}"),
                  if (isOutOfStock)
                    Text(
                      "OUT OF STOCK",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Text("Available Stock: ${product.stock}"),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.add_shopping_cart,
                  color: isOutOfStock ? Colors.grey : Colors.green,
                ),
                onPressed: isOutOfStock
                    ? null
                    : () {
                  try {
                    cartProvider.addToCart(product);
                    int newStock = product.stock - 0;
                    updateProductStock(product.id, newStock);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${product.name} added to cart!")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAuthDialog,
        tooltip: 'Admin Actions',
        child: Icon(Icons.add),
      ),
    );
  }
}