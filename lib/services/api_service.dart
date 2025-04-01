import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2/farmis_api";

  // Fetch all products
  static Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse("$baseUrl/get_products.php"));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load products");
    }
  }

  // Add new product
  static Future<void> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse("$baseUrl/add_product.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to add product: ${response.body}");
    }
  }

  // Update product (full update - name, price, stock)
  static Future<void> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse("$baseUrl/update_product.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'stock': product.stock,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update product: ${response.body}");
    }
  }

  // Delete product
  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/delete_product.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete product: ${response.body}");
    }
  }

  // Update only product stock (for quick cart updates)
  static Future<void> updateProductStock(int productId, int newStock) async {
    final response = await http.put(
      Uri.parse("$baseUrl/update_product.php"), // Using the same endpoint
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'id': productId,
        'stock': newStock,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update stock: ${response.body}");
    }
  }
}