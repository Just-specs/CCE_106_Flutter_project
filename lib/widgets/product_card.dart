import 'package:flutter/material.dart';
import '../models/product.dart';
import '../pages/details_screen.dart' as details;
// import '../pages/favourites_info.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final void Function(int)? onNavigateTab;
  final VoidCallback? onAddToCart;
  const ProductCard({super.key, required this.product, this.onNavigateTab, this.onAddToCart});

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
  }

  void _goToDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => details.DetailsScreen(product: widget.product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _goToDetails,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Center(
                    child: Image.asset(
                      widget.product.image,
                      height: 105,
                      fit: BoxFit.cover,
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
                        // Removed SnackBar for 'Added to Favorites' and 'Go to Favorites' action
                        // ...removed AlertDialog for 'Added to Favourites!'
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(widget.product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(widget.product.category,
                  style: const TextStyle(color: Colors.pink)),
              const SizedBox(height: 2),
              Text('₱${_formatPrice(widget.product.price)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Add to Cart'),
                    onPressed: () {
                      if (!ProductCard.cartProducts.contains(widget.product)) {
                        ProductCard.cartProducts.add(widget.product);
                        if (widget.onAddToCart != null) {
                          widget.onAddToCart!();
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.product.name} added to cart!'),
                            backgroundColor: Colors.deepPurple,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.product.name} is already in cart!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
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
