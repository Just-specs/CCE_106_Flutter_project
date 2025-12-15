class Order {
  final String id;
  final String item;
  String status; // e.g., 'Pending', 'Delivered', 'Cancelled'

  Order({required this.id, required this.item, this.status = 'Pending'});

  static List<Order> orders = [
    Order(id: '1001', item: 'Bouquet', status: 'Delivered'),
    Order(id: '1002', item: 'Gift Box', status: 'Pending'),
  ];

  static void addOrder(Order order) {
    orders.insert(0, order);
  }
}
