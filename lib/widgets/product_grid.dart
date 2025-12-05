import 'package:flutter/material.dart';

class ProductGrid extends StatelessWidget {
  final List<Widget> products;

  const ProductGrid({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return products[index];
      },
      physics: AlwaysScrollableScrollPhysics(),
    );
  }
}
