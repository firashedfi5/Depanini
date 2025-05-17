import 'package:depanini/screens/auth/forget_password_screen.dart';
import 'package:depanini/screens/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as dev;

final _firebase = FirebaseAuth.instance;

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() {
    return _SigninScreenState();
  }
}

class _SigninScreenState extends State<SigninScreen> {
  // ************Form*************
  final TextEditingController _enteredEmail = TextEditingController();
  final TextEditingController _enteredPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    // print(_enteredEmail);// print(_enteredPassword);
    _formKey.currentState!.save();
    // **************Firabese Auth********************
    try {
      final userCredential = await _firebase.signInWithEmailAndPassword(
        email: _enteredEmail.text,
        password: _enteredPassword.text,
      );
      dev.log(userCredential.toString());
    } on FirebaseAuthException catch (error) {
      if (error.code == 'invalid-email') {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cet email est mal formaté',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: const Color(0xffb3261e),
            ),
          );
        }
      } else if (error.code == 'user-disabled') {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Ce compte a été désactivé. Veuillez contacter le support.',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: const Color(0xffb3261e),
            ),
          );
        }
      } else if (error.code == 'user-not-found') {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Aucun compte trouvé avec cet email.',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: const Color(0xffb3261e),
            ),
          );
        }
      } else if (error.code == 'wrong-password') {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Mot de passe incorrect. Veuillez réessayer.',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: const Color(0xffb3261e),
              // behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Une erreur est survenue. Veuillez réessayer.',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: const Color(0xffb3261e),
            ),
          );
        }
      }
    }
  }
  // ********************************

  @override
  void dispose() {
    super.dispose();
    _enteredEmail.dispose();
    _enteredPassword.dispose();
  }

  bool _isVisible = false;
  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 10),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            // spacing: 10,
            children: [
              Text(
                'Se connecter à Depanini',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              const Image(
                image: AssetImage('assets/images/Mobile_login_bro.png'),
                width: 200,
              ),
              Form(
                key: _formKey,
                child: SizedBox(
                  height: 350,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 350,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Adresse Email',
                            hintText: 'Entrez votre email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez entrer votre email';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredEmail.text = newValue!;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 350,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Mot de Passe',
                            hintText: 'Entrez votre mot de passe',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isVisible = !_isVisible;
                                });
                              },
                              icon:
                                  _isVisible
                                      ? const Icon(Icons.visibility)
                                      : const Icon(Icons.visibility_off),
                            ),
                          ),
                          obscureText: !_isVisible,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Veuillez entrer votre mot de passe';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredPassword.text = newValue!;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text('Se connecter'),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.only(right: 35),
                            overlayColor: Colors.transparent,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgetPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Mot de passe oublié?',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.5,
                            ),
                          ),
                        ),
                      ),
                      const Divider(
                        thickness: 2,
                        height: 30,
                        indent: 35,
                        endIndent: 35,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Vous n\'avez pas de compte?',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignupScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign up',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
