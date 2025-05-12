import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:depanini/screens/admin/admin_diy_screen.dart';
import 'package:depanini/screens/admin/admin_profil_screen.dart';
import 'package:depanini/screens/admin/admin_user_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0;

  void _navigateGoogleNavbar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    AdminUserManagementScreen(),
    AdminDiyScreen(),
    AdminProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      // IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor!,
        animationDuration: Duration(milliseconds: 300),
        onTap: _navigateGoogleNavbar,
        items: [
          FaIcon(FontAwesomeIcons.users),
          Icon(Icons.tips_and_updates),
          Icon(Icons.account_circle),
        ],
      ),
    );
  }
}
