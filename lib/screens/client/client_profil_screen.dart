import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/screens/client/profil/client_account_screen.dart';
import 'package:depanini/screens/common/change_location.dart';
import 'package:depanini/screens/common/change_password_screen.dart';
import 'package:depanini/theme/theme_provider.dart';
import 'package:depanini/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as dev;

final _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class ProfilScreen extends ConsumerStatefulWidget {
  const ProfilScreen({super.key});

  @override
  ConsumerState<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends ConsumerState<ProfilScreen> {
  // *********Social Media*****************
  Future<void> openSocial({
    required String appName,
    required String username,
  }) async {
    final Uri socialUri = Uri.parse("https://www.$appName.com/$username");

    if (await canLaunchUrl(socialUri)) {
      await launchUrl(socialUri, mode: LaunchMode.externalApplication);
    } else {
      dev.log("Could not launch App");
    }
  }
  // *********Social Media*****************

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
                    const SizedBox(height: 10),
                    Text(
                      userData['Nom d\'utilisateur'],
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'Modifier le profil',
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                  SizedBox(height: 7),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePasswordScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'Changer le mot de passe',
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                  SizedBox(height: 7),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeLocation(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'Changer votre adresse',
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                  SizedBox(height: 7),
                  TextButton(
                    onPressed: () {},
                    child: Row(
                      children: [
                        Text(
                          'Support',
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                  SizedBox(height: 7),
                  TextButton(
                    onPressed: () {},
                    child: Row(
                      children: [
                        Text(
                          'A propos de nous',
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                  SizedBox(height: 7),
                  TextButton(
                    onPressed: () {},
                    child: Row(
                      children: [
                        Text(
                          'Changer le thème',
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                        Spacer(),
                        Switch(
                          value: themeData == darkTheme,
                          onChanged: (bool value) {
                            ref.read(themeProvider.notifier).toggleTheme();
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton.icon(
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
                  SizedBox(height: 20),
                  Text(
                    'Suivez-nous',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          openSocial(appName: 'facebook', username: 'zuck');
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.facebook,
                          color: Theme.of(context).colorScheme.primary,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 30),
                      IconButton(
                        onPressed: () {
                          openSocial(
                            appName: 'instagram',
                            username: 'elonrmuskk',
                          );
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.instagram,
                          color: Theme.of(context).colorScheme.primary,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 20),
                      IconButton(
                        onPressed: () {
                          openSocial(appName: 'x', username: 'elonmusk');
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.twitter,
                          color: Theme.of(context).colorScheme.primary,
                          size: 30,
                        ),
                      ),
                    ],
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
