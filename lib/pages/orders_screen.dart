
import 'package:flutter/material.dart';
import 'package:fresh_petals/models/order.dart';


class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item: ${order.item}'),
            Text('Status: ${order.status}'),
            const SizedBox(height: 8),
            if (order.status == 'Pending')
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    order.status = 'Delivered';
                  });
                  Navigator.pop(context);
                },
                child: const Text('Mark as Received'),
              ),
            if (order.status == 'Delivered')
              Text('Thank you for confirming receipt!', style: TextStyle(color: Colors.green)),
            if (order.status == 'Pending')
              TextButton(
                onPressed: () {
                  setState(() {
                    order.status = 'Cancelled';
                  });
                  Navigator.pop(context);
                },
                child: const Text('Cancel Order', style: TextStyle(color: Colors.red)),
              ),
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
        itemCount: Order.orders.length,
        itemBuilder: (context, index) {
          final order = Order.orders[index];
          Color statusColor;
          switch (order.status) {
            case 'Delivered':
              statusColor = const Color.fromARGB(255, 53, 145, 102);
              break;
            case 'Cancelled':
              statusColor = Colors.red;
              break;
            default:
              statusColor = Colors.orange;
          }
          return Card(
            child: ListTile(
              title: Text('Order #${order.id}'),
              subtitle: Text(order.item),
              trailing: Text(order.status, style: TextStyle(color: statusColor)),
              onTap: () => _showOrderDetails(order),
            ),
          );
        },
      ),
    );
  }
}
