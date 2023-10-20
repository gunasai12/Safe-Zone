import 'package:crime_alert_app/main.dart';
import 'package:flutter/material.dart';

class CustomMenuBar extends StatefulWidget {
  @override
  _CustomMenuBarState createState() => _CustomMenuBarState();
}

class _CustomMenuBarState extends State<CustomMenuBar> {
  int _selectedIndex = 0;
  bool isMenuOpen = false;

  final List<MenuItem> _menuItems = [
    MenuItem(icon: Icons.home, title: 'Home'),
    MenuItem(icon: Icons.explore, title: 'Explore'),
    MenuItem(icon: Icons.notifications, title: 'Notifications'),
    MenuItem(icon: Icons.person, title: 'Profile'),
    MenuItem(icon: Icons.group, title: 'Community Support'), // Added "Community Support"
    MenuItem(icon: Icons.warning, title: 'Precautions'), // Added "Precautions"
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isMenuOpen) {
          // Close the menu when tapping outside
          setState(() {
            isMenuOpen = false;
          });
        }
      },
      child: Stack(
        children: [
          // Main page content
          MyApp(),
          // Custom menu bar
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                // Prevent closing the menu when tapping inside it
                isMenuOpen = true;
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.25, // 25% of screen width
                color: Colors.blue, // Set your desired background color
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var index = 0; index < _menuItems.length; index++)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        child: MenuItemWidget(
                          icon: _menuItems[index].icon,
                          title: _menuItems[index].title,
                          isSelected: index == _selectedIndex,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuItem {
  final IconData icon;
  final String title;

  MenuItem({required this.icon, required this.title});
}

class MenuItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;

  MenuItemWidget({
    required this.icon,
    required this.title,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isSelected ? Colors.white : Colors.blue,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.white,
            size: 24, // Adjust the icon size as needed
          ),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.white,
              fontSize: 10, // Adjust the font size as needed
            ),
          ),
        ],
      ),
    );
  }
}
