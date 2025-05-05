import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _isVisible1 = false;
  bool _isVisible2 = false;
  bool _isVisible3 = false;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> changePassword(String oldPassword, String newPassword) async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && user.email != null) {
      try {
        // Re-authenticate the user with the old password
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPassword,
        );
        await user.reauthenticateWithCredential(cred);

        // Update password if re-authentication is successful
        await user.updatePassword(newPassword);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Mot de passe changé avec succès.',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        }
        // Navigator.pop(
        //   context,
        //   MaterialPageRoute(
        //     builder: (BuildContext context) => const ProfilPage(),
        //   ),
        // );
      } catch (e) {
        dev.log("Erreur : $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Ancien mot de passe est incorrect !',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: Color(0xffb3261e),
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Navigator.of(context).pop();
        }
      }
    }
  }

  void _submit() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      dev.log(_oldPasswordController.text);
      dev.log(_newPasswordController.text);
      dev.log(_confirmNewPasswordController.text);
      changePassword(_oldPasswordController.text, _newPasswordController.text);
    }
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    super.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Changer le mot de passe')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 70),
              Image.asset('assets/images/change_password.png', width: 200),
              SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      width: 350,
                      child: TextFormField(
                        controller: _oldPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Ancien mot de passe',
                          prefixIcon: Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isVisible1 = !_isVisible1;
                              });
                            },
                            icon:
                                _isVisible1
                                    ? Icon(Icons.visibility)
                                    : Icon(Icons.visibility_off),
                          ),
                        ),
                        obscureText: !_isVisible1,
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 350,
                      child: TextFormField(
                        controller: _newPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Nouveau mot de passe',
                          prefixIcon: Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isVisible2 = !_isVisible2;
                              });
                            },
                            icon:
                                _isVisible2
                                    ? Icon(Icons.visibility)
                                    : Icon(Icons.visibility_off),
                          ),
                        ),
                        obscureText: !_isVisible2,
                        validator: (value) {
                          if (value != _confirmNewPasswordController.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 350,
                      child: TextFormField(
                        controller: _confirmNewPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirmer le nouveau mot de passe',
                          prefixIcon: Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isVisible3 = !_isVisible3;
                              });
                            },
                            icon:
                                _isVisible3
                                    ? Icon(Icons.visibility)
                                    : Icon(Icons.visibility_off),
                          ),
                        ),
                        obscureText: !_isVisible3,
                        validator: (value) {
                          if (value != _newPasswordController.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text('Enregistrer'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
