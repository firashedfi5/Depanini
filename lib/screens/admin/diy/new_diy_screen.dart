import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/constants/domains.dart';
import 'package:depanini/widgets/post_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

final _firestore = FirebaseFirestore.instance;

class NewDiyScreen extends StatefulWidget {
  const NewDiyScreen({super.key});

  @override
  State<NewDiyScreen> createState() => _NewDiyScreenState();
}

class _NewDiyScreenState extends State<NewDiyScreen> {
  final uuid = Uuid();
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
    final storageRef = FirebaseStorage.instance
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
      // if (mounted) {
      //   dev.log(Navigator.of(context).canPop().toString());
      //   Navigator.of(context).pop(true);
      // }
      // *************************************
      _formKey.currentState!.save();
      // *************************************
      String? uploadedPostImageUrl_1;
      if (_foregroundImageFile != null) {
        uploadedPostImageUrl_1 = await uploadImageToFirebaseStorage(
          _foregroundImageFile!,
          1,
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
                    maxLength: 150,
                    decoration: const InputDecoration(
                      alignLabelWithHint: true,
                      label: Text('Description'),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length <= 5 ||
                          value.trim().length > 150) {
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
