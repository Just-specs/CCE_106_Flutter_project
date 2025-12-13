import 'package:flutter/material.dart';
import '../models/product.dart';
import '../pages/details_screen.dart' as details;
// import '../pages/favourites_info.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final void Function(int)? onNavigateTab;
  final VoidCallback? onAddToCart;
  final VoidCallback? onFavoriteChanged;
  final double? imageSize;
  const ProductCard({super.key, required this.product, this.onNavigateTab, this.onAddToCart, this.onFavoriteChanged, this.imageSize});

  static List<Product> cartProducts = [];

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool isFavorite;

  String _formatPrice(double price) {
    return price.toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    isFavorite = widget.product.isFavorite;
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
      widget.product.isFavorite = isFavorite;
    });
    if (widget.onFavoriteChanged != null) {
      widget.onFavoriteChanged!();
    }
  }

  void _goToDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => details.DetailsScreen(
          product: widget.product,
          onAddToCart: widget.onAddToCart,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _goToDetails,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 3,
        color: const Color(0xFFE6E6FA),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        widget.product.image,
                        fit: BoxFit.cover,
                        width: widget.imageSize ?? 120,
                        height: widget.imageSize ?? 120,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.pink : Colors.grey,
                      ),
                      onPressed: () {
                        _toggleFavorite();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                widget.product.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.product.category,
                style: const TextStyle(color: Colors.pink, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                '₱${_formatPrice(widget.product.price)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF9575CD)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
