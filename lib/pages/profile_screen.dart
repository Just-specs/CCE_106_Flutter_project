
import 'package:flutter/material.dart';
import 'package:fresh_petals/pages/address_book_screen.dart';
import 'orders_screen.dart';
import 'reminders_screen.dart';
import 'contact_us_screen.dart';
import 'manage_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "Reon Depacaquibo";
  String phone = "+63 970 247 4515";
  String email = "reon@email.com";
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
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
                      backgroundColor: Color(0xFF00BFAE),
                      child: Icon(Icons.person, size: 38, color: Colors.white),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF212121))),
                          const SizedBox(height: 6),
                          Text(phone, style: const TextStyle(fontSize: 15, color: Color(0xFF757575))),
                          const SizedBox(height: 4),
                          Text(email, style: const TextStyle(fontSize: 15, color: Color(0xFF757575))),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ManageProfileScreen(
                                    name: name,
                                    phone: phone,
                                    email: email,
                                  ),
                                ),
                              );
                              if (result != null && result is Map<String, String>) {
                                setState(() {
                                  name = result['name'] ?? name;
                                  phone = result['phone'] ?? phone;
                                  email = result['email'] ?? email;
                                });
                              }
                            },
                            icon: const Icon(Icons.edit, size: 18, color: Color(0xFF00BFAE)),
                            label: const Text('Edit Profile', style: TextStyle(color: Color(0xFF00BFAE))),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size(0, 32),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Actions Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 3,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.location_on, color: Color(0xFF448AFF)),
                      title: const Text('Address Book', style: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFBDBDBD)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddressBookScreen()),
                        );
                      },
                    ),
                    Divider(height: 1, color: Color(0xFFF5F5F5)),
                    ListTile(
                      leading: const Icon(Icons.shopping_bag, color: Color(0xFFFFB300)),
                      title: const Text('Orders', style: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFBDBDBD)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OrdersScreen()),
                        );
                      },
                    ),
                    Divider(height: 1, color: Color(0xFFF5F5F5)),
                    ListTile(
                      leading: const Icon(Icons.alarm, color: Color(0xFF00BFAE)),
                      title: const Text('Reminders', style: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFBDBDBD)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RemindersScreen()),
                        );
                      },
                    ),
                    Divider(height: 1, color: Color(0xFFF5F5F5)),
                    ListTile(
                      leading: const Icon(Icons.contact_mail, color: Color(0xFF448AFF)),
                      title: const Text('Contact Us', style: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFBDBDBD)),
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
            ),
            // ...existing code...
          ],
        ),
      ),
    );
  }
}
