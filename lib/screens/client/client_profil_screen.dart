import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/screens/client/client_diy_screen.dart';
import 'package:depanini/screens/client/profil/client_settings_screen.dart';
// import 'package:depanini/theme/theme_provider.dart';
// import 'package:depanini/theme/themes.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as dev;

final _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
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
    // final themeData = ref.watch(themeProvider);
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
                                userData['Photo de profile']!,
                                cacheKey: userData['Photo de profile']!,
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
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ClientSettingsScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.settings, size: 25),
                        const SizedBox(width: 10),
                        Text(
                          'Paramètres',
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ClientDiyScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.tips_and_updates, size: 25),
                        const SizedBox(width: 10),
                        Text(
                          'Astuces de bricolages',
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
                        const Icon(Icons.headset_mic, size: 25),
                        const SizedBox(width: 10),
                        Text(
                          'Support',
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
                        const Icon(Icons.info, size: 25),
                        const SizedBox(width: 10),
                        Text(
                          'A propos de nous',
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
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
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
                  const SizedBox(height: 20),
                  Text(
                    'Suivez-nous',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
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
                      const SizedBox(width: 30),
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
                      const SizedBox(width: 20),
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
