import 'package:flutter/material.dart';
import '../models/product.dart';
import '../pages/details_screen.dart';
import '../pages/favorite_screen.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool isFavorite;

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  void initState() {
    super.initState();
    isFavorite = FavoriteScreen.favoriteProducts.any(
      (p) => p.id == widget.product.id,
    );
  }

  void _toggleFavorite() {
    final existingIndex = FavoriteScreen.favoriteProducts.indexWhere(
      (p) => p.id == widget.product.id,
    );

    if (existingIndex >= 0) {
      FavoriteScreen.favoriteProducts.removeAt(existingIndex);
    } else {
      FavoriteScreen.favoriteProducts.add(widget.product);
    }

    setState(() => isFavorite = !isFavorite);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoriteScreen()),
    ).then((_) {
      // Refresh when returning from favorite screen
      setState(() {
        isFavorite = FavoriteScreen.favoriteProducts.any(
          (p) => p.id == widget.product.id,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsScreen(product: widget.product),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey.withOpacity(0.1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _toggleFavorite,
                    child: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border_outlined,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              Center(
                child: SizedBox(
                  height: 130,
                  width: 130,
                  child: Image.asset(widget.product.image, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.product.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.product.category,
                    style: TextStyle(color: Colors.pink, fontSize: 12),
                  ),
                  Text(
                    '₱${_formatPrice(widget.product.price)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
