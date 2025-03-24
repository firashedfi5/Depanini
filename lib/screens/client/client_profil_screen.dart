import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/screens/client/client_account_screen.dart';
import 'package:depanini/theme/theme_provider.dart';
import 'package:depanini/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class ProfilScreen extends ConsumerStatefulWidget {
  const ProfilScreen({super.key});

  @override
  ConsumerState<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends ConsumerState<ProfilScreen> {
  late Stream<DocumentSnapshot> userStream;
  final user = _auth.currentUser!;

  @override
  void initState() {
    super.initState();
    userStream = _firestore.collection("clients").doc(user.uid).snapshots();
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

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  child: Column(
                    children: [
                      const SizedBox(height: 80),
                      CircleAvatar(
                        radius: 75,
                        foregroundImage:
                            userData['Photo de profile'] != null
                                ? NetworkImage(userData['Photo de profile'])
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
                      const SizedBox(height: 20),
                      Text(
                        userData['Nom d\'utilisateur'],
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 500,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AccountScreen(),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Modifier le profil',
                                style: TextStyle(fontSize: 20),
                              ),
                              Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      SizedBox(
                        width: 500,
                        child: TextButton(
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Support', style: TextStyle(fontSize: 20)),
                              Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      SizedBox(
                        width: 500,
                        child: TextButton(
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'A propos de nous',
                                style: TextStyle(fontSize: 20),
                              ),
                              Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      SizedBox(
                        width: 500,
                        child: TextButton(
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Changer le thème',
                                style: TextStyle(fontSize: 20),
                              ),
                              Switch(
                                value: themeData == darkTheme,
                                onChanged: (bool value) {
                                  ref
                                      .read(themeProvider.notifier)
                                      .toggleTheme();
                                },
                              ),
                              // IconButton(
                              //   icon: Icon(Icons.switch_access_shortcut),
                              //   onPressed:
                              //       () =>
                              //           ref
                              //               .read(themeProvider.notifier)
                              //               .toggleTheme(),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      TextButton.icon(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                        },
                        icon: Icon(Icons.logout, color: Colors.red),
                        style: TextButton.styleFrom(),
                        label: Text(
                          "Déconnecter",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
