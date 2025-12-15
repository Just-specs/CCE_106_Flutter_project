import 'package:fresh_petals/pages/cart_screen.dart';
import 'package:fresh_petals/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:fresh_petals/pages/home_screen.dart';
import 'package:fresh_petals/pages/profile_screen.dart';
import 'package:fresh_petals/pages/categories_screen.dart';
import 'package:fresh_petals/widgets/custom_app_bar.dart';
import 'package:fresh_petals/pages/favorite_screen.dart';
import 'package:fresh_petals/models/user.dart';

class HomePage extends StatefulWidget {
  final User? currentUser;
  
  const HomePage({super.key, this.currentUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = '';
  String city = "Davao City";

  int currentIndex = 0;
  late List<Widget> screens;
  int cartCount = 0;

  @override
  void initState() {
    super.initState();
    _updateScreens();
  }

  void _updateScreens() {
    int totalCartQuantity = 0;
    for (var p in ProductCard.cartProducts) {
      totalCartQuantity += p.quantity;
    }
    screens = [
      HomeScreen(
        onNavigateTab: (tabIndex) {
          setState(() {
            currentIndex = tabIndex;
          });
        },
        onAddToCart: () {
          setState(() {
            cartCount = ProductCard.cartProducts.fold(0, (sum, p) => sum + p.quantity);
          });
        },
        searchQuery: searchQuery,
      ),
      const CategoriesScreen(),
      // Show the actual cart screen at index 2
      const CartScreen(),
      const FavoriteScreen(),
      ProfileScreen(currentUser: widget.currentUser),
    ];
    cartCount = totalCartQuantity;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: currentIndex == 0
          ? PreferredSize(
              preferredSize: const Size.fromHeight(120),
              child: CustomAppBar(
                city: city,
                onCityChanged: (String? newCity) {
                  if (newCity != null) {
                    setState(() {
                      city = newCity;
                    });
                  }
                },
                onSearch: (query) {
                  setState(() {
                    searchQuery = query;
                    _updateScreens();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                content: Align(
                alignment: Alignment.centerLeft,
                child: Text('Searching for "$query"'),
                ),  
                  backgroundColor: Color.fromARGB(255, 0, 191, 174),
                    // ...existing code...
                    ),
                  );
                },
                cartCount: cartCount,
                onCartTap: () {
                  setState(() {
                    currentIndex = 2; // Go to Cart screen
                  });
                },
                onFavoriteTap: () {
                  setState(() {
                    currentIndex = 3; // Go to Favourites screen
                  });
                },
                onMessageTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Messages feature coming soon!'),
                      backgroundColor: Color(0xFF7C4DFF),
                    ),
                  );
                },
              ),
            )
          : null,
      body: screens[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Color(0xFF7C4DFF).withOpacity(0.2),
            highlightColor: Color(0xFF7C4DFF).withOpacity(0.1),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (value) {
              setState(() => currentIndex = value);
            },
            selectedItemColor: Color(0xFF7C4DFF),
            unselectedItemColor: Color(0xFF9575CD),
            backgroundColor: const Color.fromARGB(255, 248, 246, 246),
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, color: currentIndex == 0 ? Color(0xFF7C4DFF) : Color(0xFF9575CD)),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list, color: currentIndex == 1 ? Color(0xFF7C4DFF) : Color(0xFF9575CD)),
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart, color: currentIndex == 2 ? Color(0xFF7C4DFF) : Color(0xFF9575CD)),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite, color: currentIndex == 3 ? Color(0xFF7C4DFF) : Color(0xFF9575CD)),
                label: 'Favourites',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, color: currentIndex == 4 ? Color(0xFF7C4DFF) : Color(0xFF9575CD)),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}