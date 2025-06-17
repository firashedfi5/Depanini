import 'dart:developer' as dev;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/constants/domains.dart';
import 'package:depanini/widgets/post_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

final _firestore = FirebaseFirestore.instance;
final _storage = FirebaseStorage.instance;

class AjouterAstuceScreen extends StatefulWidget {
  const AjouterAstuceScreen({super.key});

  @override
  State<AjouterAstuceScreen> createState() => _AjouterAstuceScreenState();
}

class _AjouterAstuceScreenState extends State<AjouterAstuceScreen> {
  final uuid = const Uuid();
  late String astuceId;
  final List<Domains> _domains = Domains.values;
  final _formKey = GlobalKey<FormState>();
  Domains? _selectedDomain;
  Domains? _enteredDomaine;
  final TextEditingController _enteredDescription = TextEditingController();
  final TextEditingController _enteredTitle = TextEditingController();
  File? _foregroundImageFile;

  Future<String?> uploadImageToFirebaseStorage(
    File imageFile,
    int fileNumber,
  ) async {
    final storageRef = _storage
        .ref()
        .child('astuces_pictures')
        .child(astuceId)
        .child('image_${fileNumber.toString()}.jpg');
    await storageRef.putFile(imageFile);
    final imageUrl = await storageRef.getDownloadURL();
    return imageUrl;
  }

  void _savePost() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      try {
        // *************************************
        _formKey.currentState!.save();
        // *************************************
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
        String? uploadedPostImageUrl_1;
        if (_foregroundImageFile != null) {
          uploadedPostImageUrl_1 = await uploadImageToFirebaseStorage(
            _foregroundImageFile!,
            1,
          );
        }
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Astuce ajoutée avec succès.',
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
        // ***********Storing data in Firestore**************
        _firestore.collection('astuces').doc(astuceId).set({
          'astuce_id': astuceId,
          'titre': _enteredTitle.text,
          'description': _enteredDescription.text,
          'domaine': _enteredDomaine!.name,
          'foreground_image': uploadedPostImageUrl_1,
          // 'imageURL_2': uploadedPostImageUrl_2,
          // 'imageURL_3': uploadedPostImageUrl_3,
          // 'imageURL_4': uploadedPostImageUrl_4,
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
  void initState() {
    super.initState();
    astuceId = uuid.v4();
  }

  @override
  void dispose() {
    super.dispose();
    _enteredDescription.dispose();
    _enteredTitle.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une nouvelle astuces')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _enteredTitle,
                    decoration: const InputDecoration(
                      alignLabelWithHint: true,
                      label: Text('Titre'),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le titre';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredTitle.text = value!;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _enteredDescription,
                    maxLines: 4,
                    maxLength: 300,
                    decoration: const InputDecoration(
                      alignLabelWithHint: true,
                      label: Text('Description'),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length <= 15 ||
                          value.trim().length > 300) {
                        return 'Veuillez entrer votre description';
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
                  PostImage(
                    pickedImageFile: _foregroundImageFile,
                    onImagePicked: (file) {
                      setState(() {
                        _foregroundImageFile = file;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _savePost,
                    child: const Text('Ajouter'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
