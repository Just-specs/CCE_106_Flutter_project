import 'package:flutter/material.dart';
import '../models/my_products.dart';
import '../widgets/product_card.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
    void _refresh() {
      setState(() {});
    }
  @override
  Widget build(BuildContext context) {
    final favoriteProducts = MyProducts.allProducts.where((p) => p.isFavorite).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites', style: TextStyle(color: Color(0xFF212121))),
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
        child: favoriteProducts.isEmpty
            ? const Center(
                child: Text(
                  'No favourites yet!\nTap the heart icon on a product to add it here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Color(0xFF757575)),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                itemCount: favoriteProducts.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 18),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: ProductCard(
                        product: favoriteProducts[index],
                        onNavigateTab: null,
                        onAddToCart: null,
                        onFavoriteChanged: _refresh,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
