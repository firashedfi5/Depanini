import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminProfilScreen extends StatefulWidget {
  const AdminProfilScreen({super.key});

  @override
  State<AdminProfilScreen> createState() => _AdminProfilScreenState();
}

class _AdminProfilScreenState extends State<AdminProfilScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton.icon(
          onPressed: () {
            FirebaseAuth.instance.signOut();
          },
          icon: Icon(Icons.logout, color: Colors.red, size: 25),
          style: TextButton.styleFrom(),
          label: Text(
            "Se déconnecter",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
