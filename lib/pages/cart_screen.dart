import 'package:flutter/material.dart';
import '../widgets/product_card.dart';
import '../models/product.dart';
import 'sender_information_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final double shippingFee = 0.0;
  Map<int, int> quantities = {};

  @override
  void initState() {
    super.initState();
    for (var product in _getCartProducts()) {
      quantities[product.id] = 1;
    }
  }

  List<Product> _getCartProducts() {
    return List<Product>.from(ProductCard.cartProducts);
  }

  void _increment(int id) {
    setState(() {
      quantities[id] = (quantities[id] ?? 1) + 1;
    });
  }

  void _decrement(int id) {
    if ((quantities[id] ?? 1) > 1) {
      setState(() {
        quantities[id] = (quantities[id] ?? 1) - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProducts = _getCartProducts();
    double subtotal = 0.0;
    for (var product in cartProducts) {
      subtotal += product.price * (quantities[product.id] ?? 1);
    }
    double total = subtotal + shippingFee;
    const lavender = Color(0xFFB39DDB);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart', style: TextStyle(color: Color(0xFF212121))),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF212121)),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F5F5), // Soft neutral
              Color(0xFFE0E0E0), // Light gray
              Color(0xFFBDBDBD), // Medium gray
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: cartProducts.isEmpty
              ? const Center(child: Text('Cart is empty', style: TextStyle(fontSize: 18, color: Color(0xFF757575))))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartProducts.length,
                        itemBuilder: (context, index) {
                          final product = cartProducts[index];
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(product.image, height: 48, width: 48, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF212121))),
                                        Text('₱${product.price.toStringAsFixed(0)}', style: TextStyle(color: lavender, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, color: Color(0xFF757575)),
                                        onPressed: () => _decrement(product.id),
                                      ),
                                      Text('${quantities[product.id] ?? 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: Icon(Icons.add, color: lavender),
                                        onPressed: () => _increment(product.id),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Subtotal:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF757575))),
                                Text('₱${subtotal.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF212121))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Shipping Fee:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF757575))),
                                Text('₱${shippingFee.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF212121))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF212121))),
                                Text('₱${total.toStringAsFixed(0)}', style: TextStyle(color: lavender, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SenderInformationScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lavender,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                        ),
                        child: const Text('Checkout', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

