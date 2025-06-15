import 'dart:developer' as dev;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/provider_account_model.dart';
import 'package:depanini/widgets/profil_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;
final _storage = FirebaseStorage.instance;

class ProviderPersonalInfo extends StatefulWidget {
  const ProviderPersonalInfo({super.key});

  @override
  State<ProviderPersonalInfo> createState() => _ProviderPersonalInfoState();
}

class _ProviderPersonalInfoState extends State<ProviderPersonalInfo> {
  String? originalUsername;
  String? originalDescription;
  String? originalDiplome;
  String? originalPhoneNumber;
  String? originalExperience;

  late Future<Map<String, dynamic>?> userData;

  @override
  void initState() {
    super.initState();
    userData = getUserData();
  }

  final user = _auth.currentUser!;

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection("prestataires").doc(user.uid).get();
      if (doc.exists) {
        final prestataire = ProviderAccountModel.fromSnapshot(
          doc as DocumentSnapshot<Map<String, dynamic>>,
        );
        setState(() {
          originalUsername = prestataire.username;
          originalPhoneNumber = prestataire.phoneNumber;
          originalDescription = prestataire.description;
          originalDiplome = prestataire.diplome;
          originalExperience = prestataire.experience;
        });
        dev.log('Provider data: ${prestataire.username}');
        dev.log('Provider data: ${prestataire.phoneNumber}');
        dev.log('Provider data: ${prestataire.description}');
        dev.log('Provider data: ${prestataire.diplome}');
        dev.log('Provider data: ${prestataire.experience}');
        return doc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      dev.log("Error retrieving document: $e");
      return null;
    }
  }

  // ***********************
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _enteredUserName = TextEditingController();
  final TextEditingController _enteredPhoneNumber = TextEditingController();
  final TextEditingController _enteredDescription = TextEditingController();
  final TextEditingController _enteredDiplome = TextEditingController();
  var _enteredExperience = '';
  final List<String> _experience = ["1-3 ans", "4-6 ans", "+6 ans"];
  // ********************Image upload***************************
  File? _updatedImage;
  Future<String?> uploadImageToFirebaseStorage() async {
    final storageRef = _storage
        .ref()
        .child('users_profile_pictures')
        .child('prestataires_profile_pictures')
        .child('${user.uid}.jpg');
    await storageRef.putFile(_updatedImage!);
    final imageUrl = await storageRef.getDownloadURL();
    return imageUrl;
  }

  // ******************************************
  void _update() async {
    _formKey.currentState!.save();

    final hasImageChanged = _updatedImage != null;
    final hasUsernameChanged = _enteredUserName.text != originalUsername;
    final hasPhoneNumberChanged =
        _enteredPhoneNumber.text != originalPhoneNumber;
    final hasDescriptionChanged =
        _enteredDescription.text != originalDescription;
    final hasDiplomeChanged = _enteredDiplome.text != originalDiplome;
    final hasExperienceChanged = _enteredExperience != originalExperience;

    if (hasImageChanged ||
        hasUsernameChanged ||
        hasPhoneNumberChanged ||
        hasDescriptionChanged ||
        hasDiplomeChanged ||
        hasExperienceChanged) {
      DocumentSnapshot userDoc =
          await _firestore.collection('prestataires').doc(user.uid).get();
      final currentImageUrl = userDoc['Photo de profile'];

      final finalImageUrl =
          _updatedImage != null
              ? await uploadImageToFirebaseStorage()
              : currentImageUrl;
      await _firestore.collection('prestataires').doc(user.uid).update({
        'Nom d\'utilisateur': _enteredUserName.text,
        'Numéro de téléphone': _enteredPhoneNumber.text,
        'Photo de profile': finalImageUrl,
        'Description': _enteredDescription.text,
        'Diplôme': _enteredDiplome.text,
        'Experience': _enteredExperience,
      });

      final rdvRef =
          await _firestore
              .collection('rdvs')
              .where('prestataire_uid', isEqualTo: user.uid)
              .get();

      for (var doc in rdvRef.docs) {
        await doc.reference.update({
          'prestataire_username': _enteredUserName.text,
          'prestataire_profile_picture': finalImageUrl,
        });
      }
      dev.log('Compte mis à jour');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Compte mise à jour avec succès.',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veuillez changer au moins une chose pour enregistrer.',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: const Color(0xffb3261e),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
  }

  // ****************************

  @override
  void dispose() {
    super.dispose();
    _enteredUserName.dispose();
    _enteredPhoneNumber.dispose();
    _enteredDescription.dispose();
    _enteredDiplome.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier votre compte')),
      body: FutureBuilder(
        future: userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Aucune donnée trouvée"));
          }
          return SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ********************************
                  const SizedBox(height: 20),
                  ProfilImage(
                    onPickImage: (pickedImage) {
                      _updatedImage = pickedImage;
                    },
                    initialImage: NetworkImage(
                      snapshot.data!['Photo de profile'],
                    ),
                  ),
                  // ********************************
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            initialValue: snapshot.data!['Nom d\'utilisateur'],
                            decoration: const InputDecoration(
                              labelText: 'Nom d\'utilisateur',
                              hintText: 'Entrez le nom d\'utilisateur',
                              prefixIcon: Icon(Icons.account_circle_outlined),
                            ),
                            autocorrect: false,
                            enableSuggestions: false,
                            onSaved: (newValue) {
                              _enteredUserName.text = newValue!;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            initialValue: snapshot.data!['Description'],
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              hintText: 'Entrez le nom d\'utilisateur',
                              prefixIcon: Icon(Icons.description),
                            ),
                            autocorrect: false,
                            enableSuggestions: false,
                            onSaved: (newValue) {
                              _enteredDescription.text = newValue!;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            initialValue: snapshot.data!['Diplôme'],
                            decoration: const InputDecoration(
                              labelText: 'Diplôme',
                              hintText: 'Entrez le nom d\'utilisateur',
                              prefixIcon: Icon(Icons.work_outline),
                            ),
                            autocorrect: false,
                            enableSuggestions: false,
                            onSaved: (newValue) {
                              _enteredDiplome.text = newValue!;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 350,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              label: Text('Experience'),
                              prefixIcon: Icon(Icons.timer_outlined),
                            ),
                            value:
                                _experience.contains(
                                      snapshot.data!['Experience'],
                                    )
                                    ? snapshot.data!['Experience']
                                    : null,
                            items:
                                _experience.map((experience) {
                                  return DropdownMenuItem(
                                    value: experience,
                                    child: Text(experience),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _enteredExperience = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Veuillez sélectionner votre experience';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredExperience = newValue!;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            initialValue: snapshot.data!['Numéro de téléphone'],
                            decoration: const InputDecoration(
                              labelText: 'Numéro de téléphone',
                              hintText: 'Entrez le numéro de téléphone',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            keyboardType: TextInputType.phone,
                            onSaved: (newValue) {
                              _enteredPhoneNumber.text = newValue!;
                            },
                          ),
                        ),
                        const SizedBox(height: 35),
                        ElevatedButton(
                          onPressed: _update,
                          child: const Text('Enregistrer'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
