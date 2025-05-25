import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/screens/auth/signin_screen.dart';
import 'package:depanini/screens/common/change_location.dart';
import 'package:depanini/screens/common/change_password_screen.dart';
import 'package:depanini/screens/provider/profil/provider_personal_info.dart';
import 'package:depanini/screens/provider/profil/provider_gallery.dart';
import 'package:depanini/theme/theme_provider.dart';
import 'package:depanini/theme/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class ProviderSettingsScreen extends ConsumerStatefulWidget {
  const ProviderSettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProviderSettingsScreenState();
}

class _ProviderSettingsScreenState
    extends ConsumerState<ProviderSettingsScreen> {
  void showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Supprimer le compte',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer votre compte? Cette action est irréversible.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // Dismiss dialog
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Dismiss dialog
                  Navigator.of(context).pop();
                  try {
                    await _firestore
                        .collection('clients')
                        .doc(_auth.currentUser!.uid)
                        .delete();
                    await _auth.currentUser!.delete();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Account deleted successfully.'),
                        ),
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SigninScreen()),
                      );
                    }
                  } on FirebaseAuthException catch (e) {
                    if (context.mounted) {
                      if (e.code == 'requires-recent-login') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Veuillez vous réauthentifier pour supprimer votre compte.',
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Échec de la suppression du compte: ${e.message}',
                            ),
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(context) {
    final themeData = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProviderPersonalInfo(),
                  ),
                );
              },
              child: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.solidIdCard, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Information personnelles',
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangeLocation(),
                  ),
                );
              },
              child: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.mapLocationDot, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Changer votre adresse',
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
                    builder: (context) => const ProviderGallery(),
                  ),
                );
              },
              child: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.image, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Portfolio',
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
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 7),
            TextButton(
              onPressed: () => showDeleteConfirmationDialog(context),
              child: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.trash, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Supprimer votre compte',
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
          ],
        ),
      ),
    );
  }
}
