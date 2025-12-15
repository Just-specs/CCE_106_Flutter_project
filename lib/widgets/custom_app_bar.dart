import 'package:flutter/material.dart';
import 'package:fresh_petals/services/supabase_service.dart';
import 'package:fresh_petals/pages/login_screen.dart';

class CustomAppBar extends StatefulWidget {
  final String city;
  final ValueChanged<String>? onCityChanged;
  final ValueChanged<String>? onSearch;
  final int cartCount;
  final VoidCallback? onCartTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onMessageTap;
  const CustomAppBar({
    super.key,
    required this.city,
    this.onCityChanged,
    this.onSearch,
    this.cartCount = 0,
    this.onCartTap,
    this.onFavoriteTap,
    this.onMessageTap,
  });

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
    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    'Fresh Petals',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C4DFF),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Flexible(
                flex: 3,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: widget.city,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.deepPurple, size: 20),
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
              Container(
                width: 150,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.shade100.withOpacity(0.12),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(
                      color: Colors.deepPurple.shade200,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.deepPurple.shade200, size: 15),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  ),
                  style: TextStyle(color: Colors.deepPurple.shade400, fontSize: 13, fontWeight: FontWeight.w500),
                  onSubmitted: (value) {
                    if (widget.onSearch != null) {
                      widget.onSearch!(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.shade100.withOpacity(0.12),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.message, color: Colors.deepPurple.shade300, size: 18),
                  onPressed: widget.onMessageTap,
                  padding: EdgeInsets.zero,
                  splashRadius: 18,
                  tooltip: 'Messages',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  }

