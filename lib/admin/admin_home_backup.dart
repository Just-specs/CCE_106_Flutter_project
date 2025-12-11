import 'package:flutter/material.dart';
import 'package:fresh_petals/admin/product_management.dart';
import 'package:fresh_petals/models/my_products.dart';
import 'package:fresh_petals/models/user.dart';
import 'package:fresh_petals/pages/login_screen.dart';
import 'package:fresh_petals/services/supabase_service.dart';

class AdminHome extends StatelessWidget {
  final User? currentUser;
  
  const AdminHome({super.key, this.currentUser});

  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                await SupabaseService.instance.signOut();
                
                if (!context.mounted) return;
                Navigator.pop(context);
                
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout failed: '),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Dashboard',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            if (currentUser != null)
              Text(
                'Logged in as: ',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
          ],
        ),
        backgroundColor: const Color(0xFF00BFAE),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Admin!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your Fresh Petals shop',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Total Products',
                    value: MyProducts.allProducts.length.toString(),
                    icon: Icons.inventory,
                    color: const Color(0xFF00BFAE),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Categories',
                    value: '5',
                    icon: Icons.category,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Management',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildManagementCard(context, title: 'All Products', icon: Icons.inventory_2, color: const Color(0xFF00BFAE), onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductManagement(category: 'All Products')));
                  }),
                  _buildManagementCard(context, title: 'Birthday', icon: Icons.cake, color: Colors.pink, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductManagement(category: 'Birthday')));
                  }),
                  _buildManagementCard(context, title: 'Anniversary', icon: Icons.favorite, color: Colors.red, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductManagement(category: 'Anniversary')));
                  }),
                  _buildManagementCard(context, title: 'Debut', icon: Icons.stars, color: Colors.purple, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductManagement(category: 'Debut')));
                  }),
                  _buildManagementCard(context, title: 'Gift', icon: Icons.card_giftcard, color: Colors.teal, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductManagement(category: 'Gift')));
                  }),
                  _buildManagementCard(context, title: "Mother's Day", icon: Icons.emoji_emotions, color: Colors.amber, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductManagement(category: 'Mothersday')));
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.7), color],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
