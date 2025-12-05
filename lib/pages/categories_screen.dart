import 'package:flutter/material.dart';
import 'package:fresh_petals/models/my_products.dart';
import 'package:fresh_petals/widgets/product_card.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
    String searchText = '';
    String sortBy = 'Default';
    final List<String> sortOptions = ['Default', 'Price: Low to High', 'Price: High to Low', 'Name: A-Z', 'Name: Z-A'];
  int selectedOccasion = 0;
  final List<String> occasions = [
    'All Products',
    'Birthday',
    'Anniversary',
    'Debut',
    'Gift',
    'Mothersday',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Occasions', style: TextStyle(color: Color(0xFF212121))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Occasion Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(occasions.length, (index) {
                    final isSelected = selectedOccasion == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedOccasion = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
                        decoration: BoxDecoration(
                          color: isSelected ? Color(0xFF00BFAE) : Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: isSelected
                              ? [BoxShadow(color: Color(0x2200BFAE), blurRadius: 8, offset: Offset(0, 2))]
                              : [],
                        ),
                        child: Text(
                          occasions[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Color(0xFF212121),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              // Search and Sort Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Color(0xFF00BFAE)),
                          hintText: 'Search',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide(color: Color(0xFFBDBDBD)),
                          ),
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 18),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Color(0xFFBDBDBD)),
                      ),
                      child: DropdownButton<String>(
                        value: sortBy,
                        items: sortOptions.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(option, style: TextStyle(color: Color(0xFF212121))),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            sortBy = value!;
                          });
                        },
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        underline: Container(),
                        icon: Icon(Icons.arrow_drop_down, color: Color(0xFF00BFAE)),
                        dropdownColor: Color(0xFFF5F5F5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildOccasionProducts(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOccasionProducts() {
    List products;
    if (selectedOccasion == 0) {
      products = MyProducts.allProducts;
    } else {
      products = MyProducts.allProducts.where((p) => p.category == occasions[selectedOccasion]).toList();
    }
    // Filter by search
    if (searchText.isNotEmpty) {
      products = products.where((p) => p.name.toLowerCase().contains(searchText.toLowerCase())).toList();
    }
    // Sort
    if (sortBy == 'Price: Low to High') {
      products.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortBy == 'Price: High to Low') {
      products.sort((a, b) => b.price.compareTo(a.price));
    } else if (sortBy == 'Name: A-Z') {
      products.sort((a, b) => a.name.compareTo(b.name));
    } else if (sortBy == 'Name: Z-A') {
      products.sort((a, b) => b.name.compareTo(a.name));
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(product: product);
      },
    );
  }
}
