import 'package:flutter/material.dart';
import 'package:fresh_petals/pages/address_book_screen.dart';
import 'package:fresh_petals/models/user.dart';
import 'orders_screen.dart';
import 'reminders_screen.dart';
import 'contact_us_screen.dart';
import 'manage_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User? currentUser;
  
  const ProfileScreen({super.key, this.currentUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String name;
  late String email;
  String phone = "+63 970 247 4515";
  
  @override
  void initState() {
    super.initState();
    name = widget.currentUser?.fullName ?? "Guest User";
    email = widget.currentUser?.email ?? "guest@email.com";
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 6,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Color(0xFFE6E6FA), // Lavender
                      child: Icon(Icons.person, size: 38, color: Color(0xFF9575CD)), // Light purple icon
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            phone,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF757575),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF757575),
                            ),
                          ),
                          if (widget.currentUser != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.currentUser!.role == 'admin'
                                    ? Colors.red.shade100
                                    : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.currentUser!.role.toUpperCase(),
                                style: TextStyle(
                                  color: widget.currentUser!.role == 'admin'
                                      ? Colors.red.shade700
                                      : Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 12),
            _buildProfileOption(
              context,
              icon: Icons.person_outline,
              label: 'Manage Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageProfileScreen(
                      name: name,
                      phone: phone,
                      email: email,
                    ),
                  ),
                );
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.location_on_outlined,
              label: 'Address Book',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddressBookScreen()),
                );
              },
            ),
            const SizedBox(height: 24),

            Text(
              'My Orders',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 12),
            _buildProfileOption(
              context,
              icon: Icons.shopping_bag_outlined,
              label: 'Orders',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrdersScreen()),
                );
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.notifications_outlined,
              label: 'Reminders',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RemindersScreen()),
                );
              },
            ),
            const SizedBox(height: 24),

            Text(
              'Support',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 12),
            _buildProfileOption(
              context,
              icon: Icons.help_outline,
              label: 'Contact Us',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactUsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFFE6E6FA), // Lavender
          child: Icon(icon, color: Color(0xFF9575CD)), // Light purple icon
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF212121),
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF757575)),
        onTap: onTap,
      ),
    );
  }
}
