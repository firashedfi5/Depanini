import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:depanini/screens/common/chatrooms_screen.dart';
// import 'package:depanini/screens/provider/provider_chat_screen.dart';
import 'package:depanini/screens/provider/provider_home_screen.dart';
import 'package:depanini/screens/provider/provider_profil_screen.dart';
import 'package:depanini/screens/provider/provider_rdv_screen.dart';
import 'package:flutter/material.dart';

class ProviderHome extends StatefulWidget {
  const ProviderHome({super.key});

  @override
  State<ProviderHome> createState() => _ProviderHomeState();
}

class _ProviderHomeState extends State<ProviderHome> {
  int _selectedIndex = 0;

  void _navigateGoogleNavbar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    ProviderHomeScreen(),
    ProviderRdvScreen(),
    ChatroomsScreen(),
    ProviderProfilScreen(),
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
          Icon(Icons.chat),
          Icon(Icons.account_circle),
        ],
      ),
    );
  }
}
