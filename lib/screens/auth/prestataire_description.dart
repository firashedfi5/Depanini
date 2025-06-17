import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/constants/domains.dart';
import 'package:depanini/providers/user_information.dart';
import 'package:depanini/screens/auth/email_verification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;
final _storage = FirebaseStorage.instance;

class PrestataireDescription extends ConsumerStatefulWidget {
  const PrestataireDescription({super.key});

  @override
  ConsumerState<PrestataireDescription> createState() =>
      _PrestataireDescriptionState();
}

class _PrestataireDescriptionState
    extends ConsumerState<PrestataireDescription> {
  // **********List***********
  final List<Domains> _domains = Domains.values;

  Domains? _selectedDomain;
  // ***********************

  // *********Image************
  File? _pickImageFile_1;
  File? _pickImageFile_2;
  File? _pickImageFile_3;
  File? _pickImageFile_4;
  // ************************
  // ************Form*************
  var _enteredDescription = '';
  Domains? _enteredDomaine;
  var _enteredDiplome = '';
  var _enteredExperience = '';
  final _formKey = GlobalKey<FormState>();
  // ********************Firebase Storage image upload***************************
  Future<String?> uploadProfileImageToFirebaseStorage(String userUid) async {
    final userInfo = ref.watch(userInformationProvdier);
    final storageRef = _storage
        .ref()
        .child('users_profile_pictures')
        .child('prestataires_profile_pictures')
        .child('$userUid.jpg');
    await storageRef.putFile(userInfo.profilImage!);
    final imageUrl = await storageRef.getDownloadURL();
    return imageUrl;
  }

  Future<String?> uploadProviderImageToFirebaseStorage({
    required String userUid,
    required File imageFile,
    required int fileNumber,
  }) async {
    final storageRef = _storage
        .ref()
        .child('prestataires_portfolio_pictures')
        .child('$userUid+$fileNumber.jpg');
    await storageRef.putFile(imageFile);
    final imageUrl = await storageRef.getDownloadURL();
    return imageUrl;
  }

  // **********************************************
  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    final userInfo = ref.watch(userInformationProvdier);
    // **************Firabese Auth********************
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: userInfo.email!,
        password: userInfo.password!,
      );
      // ******************************
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Compte créé avec succès! Un email de vérification vous a été envoyé.',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }

      var uploadedImageUrl = await uploadProfileImageToFirebaseStorage(
        userCredential.user!.uid,
      );

      // Upload service images if they exist
      String? uploadedProviderImageUrl_1;
      if (_pickImageFile_1 != null) {
        uploadedProviderImageUrl_1 = await uploadProviderImageToFirebaseStorage(
          imageFile: _pickImageFile_1!,
          userUid: userCredential.user!.uid,
          fileNumber: 1,
        );
      }
      String? uploadedProviderImageUrl_2;
      if (_pickImageFile_2 != null) {
        uploadedProviderImageUrl_2 = await uploadProviderImageToFirebaseStorage(
          imageFile: _pickImageFile_2!,
          userUid: userCredential.user!.uid,
          fileNumber: 2,
        );
      }
      String? uploadedProviderImageUrl_3;
      if (_pickImageFile_3 != null) {
        uploadedProviderImageUrl_3 = await uploadProviderImageToFirebaseStorage(
          imageFile: _pickImageFile_3!,
          userUid: userCredential.user!.uid,
          fileNumber: 3,
        );
      }
      String? uploadedProviderImageUrl_4;
      if (_pickImageFile_4 != null) {
        uploadedProviderImageUrl_4 = await uploadProviderImageToFirebaseStorage(
          imageFile: _pickImageFile_4!,
          userUid: userCredential.user!.uid,
          fileNumber: 4,
        );
      }

      // *****************Firestore*******************
      await _firestore
          .collection('prestataires')
          .doc(userCredential.user!.uid)
          .set({
            'Uid': userCredential.user!.uid,
            'Nom d\'utilisateur': userInfo.username,
            'Rôle': userInfo.role,
            'Numéro de téléphone': userInfo.phoneNumber,
            'Email': userInfo.email,
            'Description': _enteredDescription,
            'Domaine': _enteredDomaine!.name,
            'Diplôme': _enteredDiplome,
            'Experience': _enteredExperience,
            'Photo de profile': uploadedImageUrl,
            'Photo de travail n°1': uploadedProviderImageUrl_1,
            'Photo de travail n°2': uploadedProviderImageUrl_2,
            'Photo de travail n°3': uploadedProviderImageUrl_3,
            'Photo de travail n°4': uploadedProviderImageUrl_4,
            'averageRating': 0,
            'Localisation': userInfo.location!.address,
            'Latitude&Longitude': GeoPoint(
              userInfo.location!.latitude,
              userInfo.location!.longitude,
            ),
            'Inscrit Le': DateTime.now(),
            'Status': 'Activé',
          });
      // ************************************
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EmailVerificationScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cet e-mail est déjà utilisé. Veuillez vous connecter ou utiliser un autre e-mail.',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: const Color(0xffb3261e),
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
  final List<String> _experience = ["1-3 ans", "4-6 ans", "+6 ans"];
  String? _selectedExperience;
  @override
  Widget build(BuildContext context) {
    // final userInfo = ref.watch(userInformationProvdier);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                textAlign: TextAlign.center,
                'Finalisez la création de votre compte',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Form(
                  key: _formKey,
                  child: SizedBox(
                    height: 600,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              prefixIcon: Icon(Icons.description_outlined),
                            ),
                            autocorrect: false,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Veuillez entrer votre nom d\'utilisateur';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredDescription = newValue!;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 350,
                          child: DropdownButtonFormField<Domains>(
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.domain_outlined),
                              labelText: 'Domaine',
                            ),
                            value: _selectedDomain,
                            items:
                                _domains.map((domain) {
                                  return DropdownMenuItem(
                                    value: domain,
                                    child: Text(domain.name),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDomain = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Veuillez sélectionner un domaine';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredDomaine = newValue!;
                            },
                          ),
                          // ******************
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            // initialValue: userInfo.userName,
                            decoration: const InputDecoration(
                              labelText: 'Diplôme',
                              hintText: 'Entrez votre diplôme',
                              prefixIcon: Icon(Icons.work_outline),
                            ),
                            autocorrect: false,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Veuillez entrer votre nom d\'utilisateur';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredDiplome = newValue!;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 350,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              label: Text('Experience'),
                              prefixIcon: Icon(Icons.timer_outlined),
                            ),
                            value: _selectedExperience,
                            items:
                                _experience.map((experience) {
                                  return DropdownMenuItem(
                                    value: experience,
                                    child: Text(experience),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedExperience = value;
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
                        const SizedBox(height: 10),
                        Text(
                          'Ajoutez des photos de vos prestations',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 5),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () async {
                                  final pickedImage = await ImagePicker()
                                      .pickImage(
                                        source: ImageSource.gallery,
                                        imageQuality: 100,
                                        maxWidth: 150,
                                      );
                                  if (pickedImage == null) {
                                    return;
                                  }
                                  setState(() {
                                    _pickImageFile_1 = File(pickedImage.path);
                                  });
                                },
                                child: Container(
                                  height: 170,
                                  width: 170,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      100,
                                      113,
                                      109,
                                      109,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    image:
                                        _pickImageFile_1 != null
                                            ? DecorationImage(
                                              fit: BoxFit.cover,
                                              image: FileImage(
                                                _pickImageFile_1!,
                                              ),
                                            )
                                            : null,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_pickImageFile_1 == null)
                                        const Icon(Icons.add_a_photo, size: 60),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () async {
                                  final pickedImage = await ImagePicker()
                                      .pickImage(
                                        source: ImageSource.gallery,
                                        imageQuality: 100,
                                        maxWidth: 150,
                                      );
                                  if (pickedImage == null) {
                                    return;
                                  }
                                  setState(() {
                                    _pickImageFile_2 = File(pickedImage.path);
                                  });
                                },
                                child: Container(
                                  height: 170,
                                  width: 170,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      100,
                                      113,
                                      109,
                                      109,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    image:
                                        _pickImageFile_2 != null
                                            ? DecorationImage(
                                              fit: BoxFit.cover,
                                              image: FileImage(
                                                _pickImageFile_2!,
                                              ),
                                            )
                                            : null,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_pickImageFile_2 == null)
                                        const Icon(Icons.add_a_photo, size: 60),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () async {
                                  final pickedImage = await ImagePicker()
                                      .pickImage(
                                        source: ImageSource.gallery,
                                        imageQuality: 100,
                                        maxWidth: 150,
                                      );
                                  if (pickedImage == null) {
                                    return;
                                  }
                                  setState(() {
                                    _pickImageFile_3 = File(pickedImage.path);
                                  });
                                },
                                child: Container(
                                  height: 170,
                                  width: 170,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      100,
                                      113,
                                      109,
                                      109,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    image:
                                        _pickImageFile_3 != null
                                            ? DecorationImage(
                                              fit: BoxFit.cover,
                                              image: FileImage(
                                                _pickImageFile_3!,
                                              ),
                                            )
                                            : null,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_pickImageFile_3 == null)
                                        const Icon(Icons.add_a_photo, size: 60),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () async {
                                  final pickedImage = await ImagePicker()
                                      .pickImage(
                                        source: ImageSource.gallery,
                                        imageQuality: 100,
                                        maxWidth: 150,
                                      );
                                  if (pickedImage == null) {
                                    return;
                                  }
                                  setState(() {
                                    _pickImageFile_4 = File(pickedImage.path);
                                  });
                                },
                                child: Container(
                                  height: 170,
                                  width: 170,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      100,
                                      113,
                                      109,
                                      109,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    image:
                                        _pickImageFile_4 != null
                                            ? DecorationImage(
                                              fit: BoxFit.cover,
                                              image: FileImage(
                                                _pickImageFile_4!,
                                              ),
                                            )
                                            : null,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_pickImageFile_4 == null)
                                        const Icon(Icons.add_a_photo, size: 60),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: 350,
                          child: ElevatedButton(
                            onPressed: _submit,
                            child: const Text('Enregistrer'),
                          ),
                        ),
                      ],
                    ),
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
