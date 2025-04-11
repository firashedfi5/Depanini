import 'package:depanini/screens/auth/verify_email_screen.dart';
import 'package:depanini/screens/auth/signin_screen.dart';
import 'package:depanini/screens/common/splash_screen.dart';
import 'package:depanini/theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:depanini/theme/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ProviderScope(child: MyApp(lightTheme: lightTheme, darkTheme: darkTheme)),
  );
}

class MyApp extends ConsumerWidget {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  const MyApp({super.key, required this.lightTheme, required this.darkTheme});

  @override
  Widget build(context, ref) {
    final themeData = ref.watch(themeProvider);
    return MaterialApp(
      theme: themeData,

      // debugShowCheckedModeBanner: false,
      // darkTheme: darkTheme,
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
