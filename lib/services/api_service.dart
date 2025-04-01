import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  // Update with your Hostinger domain
  static const String baseUrl = "https://farmis.shop/api";

  // Fetch all products
  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_products.php"),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle both response formats:
        // 1. Direct array response (legacy)
        if (data is List) {
          return data.map((item) => Product.fromJson(item)).toList();
        }
        // 2. Structured response with status/data (new)
        else if (data['status'] == 'success') {
          return (data['data'] as List)
              .map((item) => Product.fromJson(item))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load products');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Add new product
  static Future<int> addProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add_product.php"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(product.toJson()),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        return responseData['id']; // Return the new product ID
      } else {
        throw Exception(responseData['error'] ?? 'Failed to add product');
      }
    } catch (e) {
      throw Exception('Add product failed: $e');
    }
  }

  // Update product (full update - name, price, stock)
  static Future<void> updateProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/update_product.php"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(product.toJson()),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode != 200 || responseData['status'] != 'success') {
        throw Exception(responseData['error'] ?? 'Failed to update product');
      }
    } catch (e) {
      throw Exception('Update product failed: $e');
    }
  }

  // Delete product
  static Future<void> deleteProduct(int id) async {
    try {
      final response = await http.post( // Using POST instead of DELETE for better compatibility
        Uri.parse("$baseUrl/delete_product.php"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'id': id}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode != 200 || responseData['status'] != 'success') {
        throw Exception(responseData['error'] ?? 'Failed to delete product');
      }
    } catch (e) {
      throw Exception('Delete product failed: $e');
    }
  }

  // Update only product stock (for quick cart updates)
  static Future<void> updateProductStock(int productId, int newStock) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/update_product.php"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'id': productId,
          'stock': newStock,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode != 200 || responseData['status'] != 'success') {
        throw Exception(responseData['error'] ?? 'Failed to update stock');
      }
    } catch (e) {
      throw Exception('Update stock failed: $e');
    }
  }

  // New method for checkout process
  static Future<void> processCheckout(Map<String, dynamic> checkoutData) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/checkout.php"), // You'll need to create this endpoint
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(checkoutData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode != 200 || responseData['status'] != 'success') {
        throw Exception(responseData['error'] ?? 'Checkout failed');
      }
    } catch (e) {
      throw Exception('Checkout process failed: $e');
    }
  }
}