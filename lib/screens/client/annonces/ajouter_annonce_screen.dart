import 'dart:developer' as dev;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/constants/domains.dart';
import 'package:depanini/widgets/post_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
final _storage = FirebaseStorage.instance;

class AjouterAnnonceScreen extends StatefulWidget {
  const AjouterAnnonceScreen({super.key});

  @override
  State<AjouterAnnonceScreen> createState() => _AjouterAnnonceScreenState();
}

class _AjouterAnnonceScreenState extends State<AjouterAnnonceScreen> {
  final user = _auth.currentUser!;
  final uuid = const Uuid();
  late String postId;
  final List<Domains> _domains = Domains.values;
  Domains? _selectedDomain;
  final TextEditingController _enteredDescription = TextEditingController();
  Domains? _enteredDomaine;
  File? _pickImageFile_1;
  File? _pickImageFile_2;
  File? _pickImageFile_3;
  File? _pickImageFile_4;
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  final formatter = DateFormat.yMd();

  @override
  void initState() {
    super.initState();
    postId = uuid.v4();
  }

  @override
  void dispose() {
    super.dispose();
    _enteredDescription.dispose();
  }

  // *Méthode nuploadi beha tsawer lel Firebase Storage
  Future<String?> uploadImageToFirebaseStorage(
    File imageFile,
    int fileNumber,
  ) async {
    final storageRef = _storage
        .ref()
        .child('posts_pictures')
        .child(user.uid)
        .child('$postId+${fileNumber.toString()}.jpg'); // *ficher
    await storageRef.putFile(imageFile);
    final imageUrl = await storageRef.getDownloadURL();
    return imageUrl;
  }

  // *Méthode nsajel beha l annonce
  void _savePost() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      try {
        _formKey.currentState!.save();
        dev.log(_selectedDate.toString());

        // *Méthode tbayen dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (_) => const AlertDialog(
                title: Text('Veuillez patienter'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      'Cela peut prendre quelques secondes...',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
        );

        // *Upload tsawer lel Firebase Storage idha kenhom mawjoudin
        String? uploadedPostImageUrl_1;
        if (_pickImageFile_1 != null) {
          uploadedPostImageUrl_1 = await uploadImageToFirebaseStorage(
            _pickImageFile_1!,
            1,
          );
        }
        String? uploadedPostImageUrl_2;
        if (_pickImageFile_2 != null) {
          uploadedPostImageUrl_2 = await uploadImageToFirebaseStorage(
            _pickImageFile_2!,
            2,
          );
        }
        String? uploadedPostImageUrl_3;
        if (_pickImageFile_3 != null) {
          uploadedPostImageUrl_3 = await uploadImageToFirebaseStorage(
            _pickImageFile_3!,
            3,
          );
        }
        String? uploadedPostImageUrl_4;
        if (_pickImageFile_4 != null) {
          uploadedPostImageUrl_4 = await uploadImageToFirebaseStorage(
            _pickImageFile_4!,
            4,
          );
        }

        // *Tna7i dialog w tafichi msg de succés
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Annonce ajoutée avec succès.',
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

        // *Tfetchi les données mte3 l client mel Firestore
        final user = _auth.currentUser!;
        final userDoc =
            await _firestore.collection("clients").doc(user.uid).get();
        final userData = userDoc.data();
        if (userData == null || !userData.containsKey('Nom d\'utilisateur')) {
          throw Exception("Nom d'utilisateur non trouvé pour l'utilisateur");
        }
        final username = userData['Nom d\'utilisateur'];
        final email = userData['Email'];
        final phoneNumber = userData['Numéro de téléphone'];
        final profilPictureURL = userData['Photo de profile'];

        // *Tsajel les données mte3 l annonce fel Firestore
        _firestore.collection('annonces').doc(postId).set({
          "post_id": postId,
          'uid': _auth.currentUser!.uid,
          'email': email,
          'username': username,
          'phone_number': phoneNumber,
          'profil_picture': profilPictureURL,
          'description': _enteredDescription.text,
          'service': _enteredDomaine!.name,
          'date': Timestamp.fromDate(
            DateTime(
              _selectedDate!.year,
              _selectedDate!.month,
              _selectedDate!.day,
            ),
          ),
          'imageURL_1': uploadedPostImageUrl_1,
          'imageURL_2': uploadedPostImageUrl_2,
          'imageURL_3': uploadedPostImageUrl_3,
          'imageURL_4': uploadedPostImageUrl_4,
          'createdAt': Timestamp.now(),
        });
      } catch (e) {
        dev.log('Error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Une erreur s\'est produite lors de l\'ajout de l\'annonce.',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: const Color(0xFFB00020),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une annonce')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _enteredDescription,
                    maxLines: 4,
                    maxLength: 200,
                    decoration: const InputDecoration(
                      alignLabelWithHint: true,
                      label: Text('Description'),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre description';
                      }
                      if (value.trim().length <= 15 ||
                          value.trim().length > 200) {
                        return 'La description doit contenir entre 15 et 200 caractères';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredDescription.text = value!;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<Domains>(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.domain_outlined),
                      labelText: 'Service',
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
                        return 'Veuillez sélectionner un service';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _enteredDomaine = newValue!;
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? ''
                            : formatter.format(_selectedDate!),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Row(
                        children: [
                          Text(
                            'Sélectionnez une date',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          IconButton(
                            onPressed: () async {
                              final now = DateTime.now();
                              final lastDate = DateTime(
                                now.year + 1,
                                now.month,
                                now.day,
                              );
                              final pickedDate = await showDatePicker(
                                context: context,
                                firstDate: now,
                                lastDate: lastDate,
                              );
                              setState(() {
                                _selectedDate = pickedDate;
                              });
                            },
                            icon: Icon(
                              Icons.calendar_month_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ajouter des photos',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  // ***********Images***********************
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        PostImage(
                          pickedImageFile: _pickImageFile_1,
                          onImagePicked: (file) {
                            setState(() {
                              _pickImageFile_1 = file;
                            });
                          },
                        ),
                        const SizedBox(width: 7),
                        PostImage(
                          pickedImageFile: _pickImageFile_2,
                          onImagePicked: (file) {
                            setState(() {
                              _pickImageFile_2 = file;
                            });
                          },
                        ),
                        const SizedBox(width: 7),
                        PostImage(
                          pickedImageFile: _pickImageFile_3,
                          onImagePicked: (file) {
                            setState(() {
                              _pickImageFile_3 = file;
                            });
                          },
                        ),
                        const SizedBox(width: 7),
                        PostImage(
                          pickedImageFile: _pickImageFile_4,
                          onImagePicked: (file) {
                            setState(() {
                              _pickImageFile_4 = file;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _savePost,
                    // _savePost,
                    child: const Text('Ajouter'),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
