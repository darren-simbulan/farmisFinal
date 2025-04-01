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
    await http.post(Uri.parse("$baseUrl/add_product.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(product.toJson()));
  }

  // Update product
  static Future<void> updateProduct(Product product) async {
    await http.put(Uri.parse("$baseUrl/update_product.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(product.toJson()));
  }

  // Delete product
  static Future<void> deleteProduct(int id) async {
    await http.delete(Uri.parse("$baseUrl/delete_product.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'id': id}));
  }

  // Update product stock
  static Future<void> updateProductStock(int productId, int newStock) async {
    await http.put(
      Uri.parse("$baseUrl/update_product_stock.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'id': productId,
        'stock': newStock,
      }),
    );
  }
}
