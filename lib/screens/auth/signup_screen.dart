import 'package:depanini/providers/user_information.dart';
import 'package:depanini/screens/auth/localization_screen.dart';
import 'package:depanini/widgets/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() {
    return _SignupScreenState();
  }
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  // ************Form*************
  var _enteredUserName = '';
  var _enteredPhoneNumber = '';
  var _enteredEmail = '';
  var _enteredPassword = '';
  File? _selectedImage;
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  void _submit() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      ref
          .read(userInformationProvdier.notifier)
          .updateUsername(_enteredUserName);
      ref
          .read(userInformationProvdier.notifier)
          .updatePhoneNumber(_enteredPhoneNumber);
      ref.read(userInformationProvdier.notifier).updateEmail(_enteredEmail);
      ref
          .read(userInformationProvdier.notifier)
          .updatePassword(_enteredPassword);
      ref
          .read(userInformationProvdier.notifier)
          .updateProfilImage(_selectedImage!);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (contexte) => LocalizationScreen()),
      );
    }
  }

  // ********************************
  bool _isVisible1 = false;
  bool _isVisible2 = false;
  @override
  Widget build(context) {
    final userInfo = ref.watch(userInformationProvdier);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Créer un nouveau compte',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Form(
                key: _formKey,
                child: SizedBox(
                  height: 600,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      UserImagePicker(
                        onPickImage: (pickedImage) {
                          _selectedImage = pickedImage;
                        },
                      ),
                      SizedBox(height: 15),
                      SizedBox(
                        width: 350,
                        child: TextFormField(
                          initialValue: userInfo.username,
                          decoration: InputDecoration(
                            labelText: 'Nom d\'utilisateur',
                            hintText: 'Entrez le nom d\'utilisateur',
                            prefixIcon: Icon(Icons.account_circle_outlined),
                          ),
                          autocorrect: false,
                          enableSuggestions: false,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez entrer votre nom d\'utilisateur';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredUserName = newValue!;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 350,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Numéro de téléphone',
                            hintText: 'Entrez le numéro de téléphone',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez entrer votre numéro';
                            }
                            if (value.length < 8) {
                              return 'Veuillez entrer un numéro valide';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredPhoneNumber = newValue!;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 350,
                        child: TextFormField(
                          decoration: InputDecoration(
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
                            _enteredEmail = newValue!;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 350,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Mot de Passe',
                            hintText: 'Entrez votre mot de passe',
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
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez entrer votre mot de passe';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredPassword = newValue!;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 350,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Confirmer mot de passe',
                            hintText: 'Confirmer votre mot de passe',
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
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez confirmer votre mot de passe';
                            }
                            if (value != _passwordController.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text('S\'inscrire'),
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
