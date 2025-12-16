class Order {
  final String id;
  final String item;
  final String imageUrl;
  String status; // e.g., 'Pending', 'Delivered', 'Cancelled'

  Order({
    required this.id,
    required this.item,
    required this.imageUrl,
    this.status = 'Pending',
  });

  static List<Order> orders = [];

  static void addOrder(Order order) {
    orders.insert(0, order);
  }
}
