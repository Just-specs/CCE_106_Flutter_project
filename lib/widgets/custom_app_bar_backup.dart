import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget {
  final String city;
  final ValueChanged<String>? onCityChanged;
  final ValueChanged<String>? onSearch;
  const CustomAppBar({super.key, required this.city, this.onCityChanged, this.onSearch});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                Text(
                  'Fresh Petals',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade400,
                    letterSpacing: 1.2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, size: 24, color: Colors.deepPurple),
                  tooltip: 'Logout',
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Deliver to', style: TextStyle(fontSize: 14, color: Colors.deepPurple.shade300)),
                const SizedBox(width: 6),
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
                        DropdownMenuItem(value: 'Davao City', child: Text('Davao City')),
                        DropdownMenuItem(value: 'Manila', child: Text('Manila')),
                        DropdownMenuItem(value: 'Cebu', child: Text('Cebu')),
                      ],
                      onChanged: (value) {
                        if (value != null && widget.onCityChanged != null) {
                          widget.onCityChanged!(value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  flex: 5,
                  child: Container(
                    height: 36,
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
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search, color: Colors.deepPurple.shade200, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      ),
                      style: TextStyle(color: Colors.deepPurple.shade400, fontSize: 14),
                      onSubmitted: (value) {
                        if (widget.onSearch != null) {
                          widget.onSearch!(value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
