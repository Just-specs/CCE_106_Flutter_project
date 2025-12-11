import 'package:fresh_petals/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:fresh_petals/pages/home_screen.dart';
import 'package:fresh_petals/pages/profile_screen.dart';
import 'package:fresh_petals/pages/categories_screen.dart';
import 'package:fresh_petals/pages/cart_screen.dart';
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
    screens = [
      HomeScreen(
        onNavigateTab: (tabIndex) {
          setState(() {
            currentIndex = tabIndex;
          });
        },
        onAddToCart: () {
          setState(() {
            cartCount = ProductCard.cartProducts.length;
          });
        },
        searchQuery: searchQuery,
      ),
      const CategoriesScreen(),
      const CartScreen(),
      const FavoriteScreen(),
      ProfileScreen(currentUser: widget.currentUser),
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: currentIndex == 0
          ? PreferredSize(
              preferredSize: const Size.fromHeight(120),
              child: CustomAppBar(
                city: city,
                onCityChanged: (newCity) {
                  setState(() {
                    city = newCity;
                  });
                },
                onSearch: (query) {
                  setState(() {
                    searchQuery = query;
                    _updateScreens();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Searching for "$query"'),
                      backgroundColor: Color(0xFF00BFAE),
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
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (value) {
            setState(() => currentIndex = value);
          },
          selectedItemColor: Color(0xFF00BFAE),
          unselectedItemColor: Color(0xFFBDBDBD),
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: currentIndex == 0 ? Color(0xFF00BFAE) : Color(0xFFBDBDBD)),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list, color: currentIndex == 1 ? Color(0xFF448AFF) : Color(0xFFBDBDBD)),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(Icons.shopping_cart, color: currentIndex == 2 ? Color(0xFFFFB300) : Color(0xFFBDBDBD)),
                  if (cartCount > 0)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFB300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$cartCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite, color: currentIndex == 3 ? Colors.pinkAccent : Color(0xFFBDBDBD)),
              label: 'Favourites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, color: currentIndex == 4 ? Color(0xFF448AFF) : Color(0xFFBDBDBD)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}