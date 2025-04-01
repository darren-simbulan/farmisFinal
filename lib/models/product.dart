class Product {
  int id;
  String name;
  int stock;
  double price;

  Product({required this.id, required this.name, required this.stock, required this.price});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      stock: int.parse(json['stock'].toString()),
      price: double.parse(json['price'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stock': stock,
      'price': price,
    };
  }
}
