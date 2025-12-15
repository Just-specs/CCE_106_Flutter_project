import 'package:flutter/material.dart';
import 'package:fresh_petals/models/my_products.dart';
import 'package:fresh_petals/models/product.dart';
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
  final bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadProducts() async {
    // No-op: products are now sourced from MyProducts.allProducts
  }

  @override
  Widget build(BuildContext context) {
    // Filter products based on search query from MyProducts.allProducts
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
      color: Color(0xFFF5F5F5), // Light grey
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5FF), // Match outer background (very light lavender/grey)
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildContent(filteredProducts),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<Product> filteredProducts) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.deepPurple,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              widget.searchQuery.isEmpty 
                ? 'No products available'
                : 'No products found for "${widget.searchQuery}"',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      );
    }

    return ProductGrid(
        products: filteredProducts
          .map((product) => ProductCard(
            product: product,
            onNavigateTab: widget.onNavigateTab,
            onAddToCart: widget.onAddToCart,
            imageSize: 180, // Larger image for HomeScreen
            ))
          .toList(),
    );
  }
}
