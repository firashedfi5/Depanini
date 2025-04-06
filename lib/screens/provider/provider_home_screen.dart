import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _auth = FirebaseAuth.instance;

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Provider Home Screen',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                _auth.signOut();
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
          ],
        ),
      ),
    );
  }
}
