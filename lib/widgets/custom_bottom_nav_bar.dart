import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ...existing code...
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.grey[700],
      unselectedItemColor: Colors.grey[500],
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: _BorderedIcon(Icons.home, isSelected: currentIndex == 0),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: _BorderedIcon(Icons.list, isSelected: currentIndex == 1),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: _BorderedIcon(Icons.shopping_cart, isSelected: currentIndex == 2),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: MessageNavIcon(isSelected: currentIndex == 3),
          label: 'Favourites',
        ),
        BottomNavigationBarItem(
          icon: _BorderedIcon(Icons.person, isSelected: currentIndex == 4),
          label: 'Profile',
        ),
      ],
    );
  }
}

// Stateful message icon for nav bar
class MessageNavIcon extends StatefulWidget {
  final bool isSelected;
  const MessageNavIcon({required this.isSelected, super.key});

  @override
  State<MessageNavIcon> createState() => _MessageNavIconState();
}

class _MessageNavIconState extends State<MessageNavIcon> {
  bool _hasUnread = false;

  @override
  Widget build(BuildContext context) {
    Color borderColor = widget.isSelected ? Colors.black : Colors.transparent;
    Color iconColor = widget.isSelected ? Colors.black : Colors.grey[700]!;
    return GestureDetector(
      onTap: () {
        setState(() {
          _hasUnread = !_hasUnread;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: Stack(
          children: [
            Icon(Icons.message, color: iconColor),
            if (_hasUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BorderedIcon extends StatefulWidget {
  final IconData icon;
  final bool isSelected;
  const _BorderedIcon(this.icon, {required this.isSelected});

  @override
  State<_BorderedIcon> createState() => _BorderedIconState();
}

class _BorderedIconState extends State<_BorderedIcon> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    Color borderColor = widget.isSelected || _hovering ? Colors.black : Colors.transparent;
    Color iconColor = _hovering ? Colors.black : Colors.grey[700]!;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: Icon(widget.icon, color: iconColor),
      ),
    );
  }
}
