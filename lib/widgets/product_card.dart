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
    int _rating = 0;

    Widget _buildStarRating() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          return IconButton(
            icon: Icon(
              index < _rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _rating = index + 1;
              });
            },
          );
        }),
      );
    }
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
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Stack(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 140,
                          maxHeight: 120,
                          minWidth: 110,
                          minHeight: 100,
                        ),
                        child: Image.asset(
                          widget.product.image,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
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
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        _toggleFavorite();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildStarRating(),
              const SizedBox(height: 2),
              Text(
                widget.product.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.product.category,
                style: const TextStyle(color: Colors.pink, fontSize: 10),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '₱${_formatPrice(widget.product.price)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color.fromARGB(255, 14, 13, 16)),
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
