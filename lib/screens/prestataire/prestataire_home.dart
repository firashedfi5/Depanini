import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:depanini/screens/commun/chatrooms_screen.dart';
import 'package:depanini/screens/prestataire/prestataire_home_screen.dart';
import 'package:depanini/screens/prestataire/prestataire_profil_screen.dart';
import 'package:depanini/screens/prestataire/prestataire_rdv_screen.dart';
import 'package:flutter/material.dart';

class PrestataireHome extends StatefulWidget {
  const PrestataireHome({super.key});

  @override
  State<PrestataireHome> createState() => _PrestataireHomeState();
}

class _PrestataireHomeState extends State<PrestataireHome> {
  int _selectedIndex = 0;

  void _navigateGoogleNavbar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const PrestataireHomeScreen(),
    const PrestataireRdvScreen(),
    const ChatroomsScreen(),
    const PrestataireProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor!,
        animationDuration: const Duration(milliseconds: 300),
        onTap: _navigateGoogleNavbar,
        items: const [
          Icon(Icons.home),
          Icon(Icons.calendar_month),
          Icon(Icons.chat),
          Icon(Icons.account_circle),
        ],
      ),
    );
  }
}
