import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:depanini/screens/client/client_post_screen.dart';
import 'package:depanini/screens/client/client_rdv_screen.dart';
import 'package:depanini/screens/common/chatrooms_screen.dart';
import 'package:depanini/screens/client/client_home_screen.dart';
import 'package:depanini/screens/client/client_profil_screen.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  void _navigateGoogleNavbar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    HomeScreen(),
    ClientRdvScreen(),
    ClientPostScreen(),
    ChatroomsScreen(),
    ProfilScreen(),
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
          Icon(Icons.home),
          Icon(Icons.calendar_month),
          Icon(Icons.post_add),
          Icon(Icons.chat),
          Icon(Icons.account_circle),
        ],
      ),
    );
  }
}
