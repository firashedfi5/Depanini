import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/screens/client/home.dart';
import 'package:depanini/screens/provider/provider_home_screen.dart';
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
  // *******************User Role************************
  Future<String?> getUserRole(String uid) async {
    final clientDoc = await _firestore.collection('clients').doc(uid).get();
    if (clientDoc.exists) return 'client';

    final providerDoc =
        await _firestore.collection('prestataires').doc(uid).get();
    if (providerDoc.exists) return 'provider';

    // Optional: check admin collection or specific UID/email
    // final user = FirebaseAuth.instance.currentUser;
    // if (user != null && user.email == 'admin@example.com') {
    //   return 'admin';
    // }

    return null;
  }

  // Future<Widget> _checkRoleAndNavigate() async {
  //   final user = _auth.currentUser!;
  //   final role = await getUserRole(user.uid);

  //   if (!mounted) {
  //     return const Home();
  //   }

  //   switch (role) {
  //     case 'provider':
  //       return const ProviderHomeScreen();
  //     // case 'admin':
  //     //   return const AdminHome();
  //     default:
  //       return const Home();
  //   }
  // }

  // Navigator.of(context).pushReplacement(
  //   MaterialPageRoute(
  //     builder: (_) {
  //       switch (role) {
  //         case 'provider':
  //           return const ProviderHomeScreen();
  //         // case 'admin':
  //         //   return const AdminHome();
  //         default:
  //           return const Home();
  //       }
  //     },
  //   ),
  // );
  // *******************User Role************************

  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(Duration(seconds: 3), (_) => checkEmailVerified());
    }
    // else {
    //   _checkRoleAndNavigate();
    // }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();
      // _checkRoleAndNavigate();
    }
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).clearSnackBars();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            // ignore: use_build_context_synchronously
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
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
              const Text(
                'Please verify your email before proceeding.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Send email verification
                  await user.sendEmailVerification();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Verification email sent! Check your inbox.',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Resend Verification Email'),
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
              return const ProviderHomeScreen();
            // case 'admin':
            //   return const AdminHome();
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
