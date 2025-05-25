import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/screens/admin/admin_home.dart';
import 'package:depanini/screens/client/home.dart';
import 'package:depanini/screens/provider/provider_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3), (_) => checkEmailVerified());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // *******************User Role************************
  Future<String?> getUserRole(String uid) async {
    try {
      final clientDoc = await _firestore.collection('clients').doc(uid).get();
      if (clientDoc.exists) return 'client';

      final providerDoc =
          await _firestore.collection('prestataires').doc(uid).get();
      if (providerDoc.exists) return 'provider';

      final adminDoc =
          await _firestore.collection('administrateurs').doc(uid).get();
      if (adminDoc.exists) return 'admin';

      // Optional: check admin collection or specific UID/email
      // final user = FirebaseAuth.instance.currentUser;
      // if (user != null && user.email == 'admin@example.com') {
      //   return 'admin';
      // }

      return null;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xffb3261e),
          ),
        );
      }
      return null;
    }
  }

  // *******************User Role************************

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();
    }
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xffb3261e),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('assets/images/Mail_sent_bro.png'),
                width: 300,
              ),
              Text(
                'Un email de vérification vous a été envoyé.',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: canResendEmail ? sendVerificationEmail : null,
                child: const Text('Renvoyer'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text('Annuler'),
              ),
            ],
          ),
        ),
      );
    }
    return FutureBuilder<String?>(
      future: getUserRole(_auth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (snapshot.hasData) {
          final role = snapshot.data;
          switch (role) {
            case 'provider':
              return const ProviderHome();
            case 'admin':
              return const AdminHome();
            case 'client':
              return const Home();
            default:
              return const Scaffold(body: Center(child: Text('Unknown role')));
          }
        } else {
          return const Scaffold(body: Center(child: Text('No data found')));
        }
      },
    );
  }
}
