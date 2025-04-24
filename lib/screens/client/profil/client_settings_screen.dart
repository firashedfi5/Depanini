import 'package:depanini/screens/client/profil/client_account_screen.dart';
import 'package:depanini/screens/common/change_location.dart';
import 'package:depanini/screens/common/change_password_screen.dart';
import 'package:depanini/theme/theme_provider.dart';
import 'package:depanini/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ClientSettingsScreen extends ConsumerWidget {
  const ClientSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final themeData = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Paramètres')),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountScreen()),
                );
              },
              child: Row(
                children: [
                  FaIcon(FontAwesomeIcons.solidIdCard, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Information personnelles',
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
                  FaIcon(FontAwesomeIcons.userShield, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Changer de mot de passe',
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
                  MaterialPageRoute(builder: (context) => ChangeLocation()),
                );
              },
              child: Row(
                children: [
                  FaIcon(FontAwesomeIcons.mapLocationDot, size: 20),
                  SizedBox(width: 10),
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
                  Icon(Icons.dark_mode, size: 20),
                  SizedBox(width: 10),
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
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
