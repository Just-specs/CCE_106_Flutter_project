class Product {
  final int id;
  final String name;
  final String category;
  final String image;
  final String description;
  final double price;
  int quantity;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.description,
    required this.price,
    required this.quantity,
    this.isFavorite = false,
  });
}
