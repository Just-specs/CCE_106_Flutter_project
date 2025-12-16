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
    int _rating = 5;
    int _reviewCount = 11;

    Widget _buildStarRating() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                // Example: cycle rating for demo
                _rating = _rating == 5 ? 4 : 5;
                _reviewCount = _rating == 5 ? 11 : 8;
              });
            },
            child: Icon(
              Icons.star,
              color: Colors.amber,
              size: 20,
              shadows: [
                Shadow(
                  blurRadius: 2,
                  color: Colors.black26,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _rating.toStringAsFixed(1),
            style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Text(
            ' ($_reviewCount)',
            style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
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
                      borderRadius: BorderRadius.circular(16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 180,
                          maxHeight: 150,
                          minWidth: 140,
                          minHeight: 120,
                        ),
                        child: Image.asset(
                          widget.product.image,
                          fit: BoxFit.cover,
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
                        size: 22,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '₱${_formatPrice(widget.product.price)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color.fromARGB(255, 14, 13, 16)),
                    ),
                  ),
                  _buildStarRating(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
