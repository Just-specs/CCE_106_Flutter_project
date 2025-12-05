import 'package:flutter/material.dart';
import 'package:fresh_petals/models/my_products.dart';
import 'package:fresh_petals/widgets/product_card.dart';
import 'package:fresh_petals/widgets/product_grid.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int)? onNavigateTab;
  final VoidCallback? onAddToCart;
  final String searchQuery;
  const HomeScreen({super.key, this.onNavigateTab, this.onAddToCart, this.searchQuery = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final filteredProducts = MyProducts.allProducts.where((product) {
      final query = widget.searchQuery.trim().toLowerCase();
      if (query.isEmpty) return true;
      return product.name.toLowerCase().contains(query) ||
             product.category.toLowerCase().contains(query) ||
             product.description.toLowerCase().contains(query);
    }).toList();

    return Container(
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ProductGrid(
                    products: filteredProducts
                        .map((product) => ProductCard(
                              product: product,
                              onNavigateTab: widget.onNavigateTab,
                              onAddToCart: widget.onAddToCart,
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
