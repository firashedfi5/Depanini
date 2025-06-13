import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/screens/common/change_password_screen.dart';
import 'package:depanini/theme/theme_provider.dart';
import 'package:depanini/theme/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class AdminProfilScreen extends ConsumerStatefulWidget {
  const AdminProfilScreen({super.key});

  @override
  ConsumerState<AdminProfilScreen> createState() => _AdminProfilScreenState();
}

class _AdminProfilScreenState extends ConsumerState<AdminProfilScreen> {
  late Stream<DocumentSnapshot> userStream;
  final user = _auth.currentUser!;

  @override
  void initState() {
    super.initState();
    userStream =
        _firestore.collection("administrateurs").doc(user.uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeProvider);
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Aucune donnée trouvée"));
          }

          // Extract user data from DocumentSnapshot
          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 75,
                      foregroundImage:
                          userData['Photo de profile'] != null
                              ? CachedNetworkImageProvider(
                                userData['Photo de profile'],
                                cacheKey: userData['Photo de profile'],
                              )
                              : null,
                      child:
                          userData['Photo de profile'] == null
                              ? const Icon(
                                Icons.person,
                                size: 70,
                                color: Colors.white,
                              )
                              : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userData['Nom d\'utilisateur'],
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.userShield, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Changer de mot de passe',
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                  const SizedBox(height: 7),
                  TextButton(
                    onPressed: () {},
                    child: Row(
                      children: [
                        const Icon(Icons.dark_mode, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Changer le thème',
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: themeData == darkTheme,
                          onChanged: (bool value) {
                            ref.read(themeProvider.notifier).toggleTheme();
                            // Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextButton.icon(
                    onPressed: () {
                      _auth.signOut();
                    },
                    icon: const Icon(Icons.logout, color: Colors.red, size: 25),
                    style: TextButton.styleFrom(),
                    label: const Text(
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
            ],
          );
        },
      ),
    );
  }
}
