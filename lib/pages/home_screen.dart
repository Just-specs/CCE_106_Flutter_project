import 'package:flutter/material.dart';
import 'package:fresh_petals/models/my_products.dart';
import 'package:fresh_petals/widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int isSelected = 0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Occasions",
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildProductCategory(index: 0, name: "All Products"),
                _buildProductCategory(index: 1, name: "Birthday"),
                _buildProductCategory(index: 2, name: "Anniversary"),
                _buildProductCategory(index: 3, name: "Debut"),
                _buildProductCategory(index: 4, name: "Gift"),
                _buildProductCategory(index: 5, name: "Mother's Day"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // GridView must be constrained inside Column — use Expanded
          Expanded(child: _buildAllProducts()),
        ],
      ),
    );
  }

  _buildProductCategory({required int index, required String name}) =>
      GestureDetector(
        onTap: () => setState(() => isSelected = index),
        child: Container(
          width: 100,
          height: 40,
          margin: const EdgeInsets.only(top: 10, right: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected == index
                ? Colors.deepPurple
                : Colors.deepPurple.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            name,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      );

  Widget _buildAllProducts() {
    final products = isSelected == 0
        ? MyProducts.allProducts
        : isSelected == 1
        ? MyProducts.birthdayList
        : isSelected == 2
        ? MyProducts.anniversaryList
        : isSelected == 3
        ? MyProducts.debutList
        : isSelected == 4
        ? MyProducts.giftList
        : MyProducts.MothersdayList;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: (100 / 140),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      padding: EdgeInsets.zero,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(product: product);
      },
    );
  }
}
