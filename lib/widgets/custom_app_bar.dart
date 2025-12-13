import 'package:flutter/material.dart';
import 'package:fresh_petals/services/supabase_service.dart';
import 'package:fresh_petals/pages/login_screen.dart';

class CustomAppBar extends StatefulWidget {
  final String city;
  final ValueChanged<String>? onCityChanged;
  final ValueChanged<String>? onSearch;
  final int cartCount;
  final VoidCallback? onCartTap;
  const CustomAppBar({super.key, required this.city, this.onCityChanged, this.onSearch, this.cartCount = 0, this.onCartTap});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final TextEditingController _searchController = TextEditingController();
  final _supabaseService = SupabaseService.instance;
  final List<String> _cities = [
    'Davao City',
    'Tagum City',
    'Panabo City',
    'Carmen',
    'Digos City',
    'Mati City',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      try {
        // Sign out from Supabase
        await _supabaseService.signOut();
        if (mounted) {
          // Navigate to login screen and remove all previous routes
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: Color(0xFFB39DDB),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Fresh Petals',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7C4DFF),
                    letterSpacing: 1.2,
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: widget.city,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.deepPurple.shade300, size: 20),
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade400, fontSize: 14),
                      dropdownColor: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(14),
                      items: [
                        ..._cities.map((city) => DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            )),
                      ],
                      onChanged: widget.onCityChanged as ValueChanged<String?>?,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: widget.onCartTap,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.shopping_cart, color: Colors.deepPurple.shade300, size: 28),
                      if (widget.cartCount > 0)
                        Positioned(
                          right: -4,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Color(0xFF1565C0), // Blue
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${widget.cartCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.deepPurple.shade300),
                  tooltip: 'Logout',
                  onPressed: _logout,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 32, top: 4),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 24 > 420 ? 420 : MediaQuery.of(context).size.width - 24,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.shade100.withOpacity(0.4),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                          color: Colors.deepPurple.shade200,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.deepPurple.shade200, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                      ),
                      style: TextStyle(color: Colors.deepPurple.shade400, fontSize: 16, fontWeight: FontWeight.w500),
                      onSubmitted: (value) {
                        if (widget.onSearch != null) {
                          widget.onSearch!(value);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  }

