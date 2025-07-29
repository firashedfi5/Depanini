import 'package:depanini/screens/auth/email_verification_screen.dart';
import 'package:depanini/screens/auth/signin_screen.dart';
import 'package:depanini/screens/commun/splash_screen.dart';
import 'package:depanini/theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'firebase_options.dart';

// import 'package:depanini/theme/themes.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();

  timeago.setLocaleMessages('fr', timeago.FrMessages());
  await initializeDateFormatting('fr_FR', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.hasData) {
          return const EmailVerificationScreen();
        } else {
          return const SigninScreen();
        }
      },
    );
  }
}
