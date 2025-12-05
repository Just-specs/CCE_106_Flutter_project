import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final List<Map<String, String>> orders = [
    {'id': '1001', 'item': 'Bouquet', 'status': 'Delivered'},
    {'id': '1002', 'item': 'Gift Box', 'status': 'Pending'},
  ];

  void _showOrderDetails(Map<String, String> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item: ${order['item']}'),
            Text('Status: ${order['status']}'),
            const SizedBox(height: 8),
            Text('Details coming soon...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            child: ListTile(
              title: Text('Order #${order['id']}'),
              subtitle: Text(order['item'] ?? ''),
              trailing: Text(order['status'] ?? '', style: TextStyle(color: order['status'] == 'Delivered' ? Colors.green : Colors.orange)),
              onTap: () => _showOrderDetails(order),
            ),
          );
        },
      ),
    );
  }
}
