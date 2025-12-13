import 'package:flutter/material.dart';
import 'package:fresh_petals/models/product.dart';

import '../widgets/product_card.dart';

class DetailsScreen extends StatefulWidget {
  final Product product;
  final VoidCallback? onAddToCart;

  const DetailsScreen({super.key, required this.product, this.onAddToCart});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int quantity = 1;

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE6E6FA), // Lavender
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Product Details', style: TextStyle(color: Colors.black)),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE6E6FA), Colors.white, Color(0xFFF5F5F5)], // Lavender, white, grey
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isPortrait ? 16.0 : mediaQuery.size.width * 0.15,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Product Image
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    alignment: Alignment.center,
                    child: Container(
                      width: isPortrait ? mediaQuery.size.width * 0.6 : 240,
                      height: isPortrait ? mediaQuery.size.width * 0.6 : 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE6E6FA), // Lighter lavender
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          widget.product.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Details Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.category,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.product.description,
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₱${_formatPrice(widget.product.price)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.deepPurple,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: quantity > 1
                                      ? () => setState(() => quantity--)
                                      : null,
                                ),
                                Text('$quantity', style: const TextStyle(fontSize: 18)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => setState(() => quantity++),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              // Add to cart logic
                              final cart = ProductCard.cartProducts;
                              final existing = cart.indexWhere((p) => p.id == widget.product.id);
                              if (existing == -1) {
                                // Add a copy with the selected quantity
                                cart.add(Product(
                                  id: widget.product.id,
                                  name: widget.product.name,
                                  category: widget.product.category,
                                  image: widget.product.image,
                                  description: widget.product.description,
                                  price: widget.product.price,
                                  quantity: quantity,
                                  isFavorite: widget.product.isFavorite,
                                ));
                              } else {
                                // Update quantity
                                cart[existing].quantity += quantity;
                              }
                              if (widget.onAddToCart != null) widget.onAddToCart!();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${widget.product.name} x $quantity added to cart!',
                                  ),
                                  backgroundColor: Colors.deepPurple,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Add to Cart',
                              style: TextStyle(fontSize: 17, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.deepPurple,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Continue Shopping',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
