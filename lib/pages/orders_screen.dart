
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

  int _selectedTab = 0;
  final List<String> _tabs = ['All', 'To Pay', 'Processing', 'Shipped', 'Delivered', 'Failed'];
  String _search = '';

  List<Order> get _filteredOrders {
    if (_selectedTab == 0 && _search.isEmpty) return Order.orders;
    return Order.orders.where((order) {
      final matchesTab = _selectedTab == 0 || order.status == _tabs[_selectedTab];
      final matchesSearch = _search.isEmpty || order.item.toLowerCase().contains(_search.toLowerCase()) || order.id.contains(_search);
      return matchesTab && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _search = val),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: _tabs.length,
              separatorBuilder: (_, __) => SizedBox(width: 8),
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                child: Column(
                  children: [
                    Text(
                      _tabs[i],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _selectedTab == i ? Colors.deepOrange : Colors.black54,
                        fontSize: 15,
                      ),
                    ),
                    if (_selectedTab == i)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        height: 2,
                        width: 28,
                        color: Colors.deepOrange,
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredOrders.isEmpty
                ? Center(
                    child: Text(
                      'No orders yet. Once you place an order, it will appear here.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, idx) {
                      final order = _filteredOrders[idx];
                      final isCancelled = order.status == 'Cancelled';
                      final isDelivered = order.status == 'Delivered';
                      final statusColor = isCancelled
                          ? Colors.green[200]
                          : isDelivered
                              ? Colors.green[400]
                              : Colors.orange[200];
                      // ...existing card code here...
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'FS-${order.id}',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isCancelled)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text('Cancelled by Customer', style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.w500, fontSize: 13)),
                                    ),
                                  if (isDelivered)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text('Delivered', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Nov 12, 2025', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                                        Text('Delivery Date', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('1PM - 5PM', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                                        Text('Delivery Time', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Show product image if available, else placeholder
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: order.imageUrl.isNotEmpty
                                          ? Image.network(
                                              order.imageUrl,
                                              width: 54,
                                              height: 54,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                width: 54,
                                                height: 54,
                                                color: Colors.grey[300],
                                                child: Icon(Icons.broken_image, color: Colors.white, size: 32),
                                              ),
                                            )
                                          : Container(
                                              width: 54,
                                              height: 54,
                                              color: Colors.grey[300],
                                              child: Icon(Icons.shopping_bag, color: Colors.white, size: 32),
                                            ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(order.item, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                                          const SizedBox(height: 2),
                                          Text('Qty: 1', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('₱1,599', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total 1 item:', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                                  Text('₱1,599', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
