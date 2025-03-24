import 'package:depanini/screens/auth/verify_email_screen.dart';
import 'package:depanini/screens/auth/signin_screen.dart';
import 'package:depanini/screens/common/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:json_theme/json_theme.dart';
import 'dart:convert';

ThemeData lightTheme = ThemeData();
ThemeData darkTheme = ThemeData();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ************************
  final themeStr = await rootBundle.loadString(
    'assets/themes/light_theme.json',
  );
  final themeJson = jsonDecode(themeStr);
  lightTheme =
      ThemeDecoder.decodeThemeData(themeJson, validate: true) ?? ThemeData();
  // ************************
  final darkThemeStr = await rootBundle.loadString(
    'assets/themes/dark_theme.json',
  );
  final darkThemeJson = jsonDecode(darkThemeStr);
  darkTheme =
      ThemeDecoder.decodeThemeData(darkThemeJson, validate: true) ??
      ThemeData();
  // ************************

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ProviderScope(child: MyApp(lightTheme: lightTheme, darkTheme: darkTheme)),
  );
}

class MyApp extends StatelessWidget {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  const MyApp({super.key, required this.lightTheme, required this.darkTheme});

  @override
  Widget build(context) {
    return MaterialApp(
      theme: lightTheme,

      darkTheme: darkTheme,

      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (contexte, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasData) {
            return const VerifyEmailScreen();
          } else {
            return const SigninScreen();
          }
        },
      ),
      // themeMode: ThemeMode.system,
    );
  }
}
