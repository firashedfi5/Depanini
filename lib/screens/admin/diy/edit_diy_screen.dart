import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/astuce_model.dart';
import 'package:depanini/widgets/update_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;

class EditDiyScreen extends StatefulWidget {
  const EditDiyScreen({
    super.key,
    required this.astuceId,
    required this.originalDescription,
    required this.originalTitle,
  });

  final String astuceId;
  final String originalDescription;
  final String originalTitle;

  @override
  State<EditDiyScreen> createState() => _EditDiyScreenState();
}

class _EditDiyScreenState extends State<EditDiyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _enteredDescription = TextEditingController();
  final TextEditingController _enteredTitle = TextEditingController();
  File? _foregroundImageFile;

  late Future<AstuceModel> _loadedAstuce;

  @override
  void initState() {
    super.initState();
    _loadedAstuce = _loadAstuce();
  }

  Future<AstuceModel> _loadAstuce() async {
    try {
      final docSnapshot =
          await _firestore.collection('astuces').doc(widget.astuceId).get();

      if (!docSnapshot.exists) {
        throw Exception('Aucune astuce trouvée pour cet identifiant.');
      }

      final data = docSnapshot.data()!;

      final post = AstuceModel(
        id: docSnapshot.id,
        createdAt: data["createdAt"],
        titre: data["titre"],
        description: data['description'],
        domaine: data['domaine'],
        foregroundImage: data["foreground_image"],
      );

      return post;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'annonce : $e');
    }
  }

  Future<String?> uploadImageToFirebaseStorage({
    required File imageFile,
    required int fileNumber,
  }) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('astuces_pictures')
        .child(widget.astuceId)
        .child('image_${fileNumber.toString()}.jpg');
    await storageRef.putFile(imageFile);
    final imageUrl = await storageRef.getDownloadURL();
    return imageUrl;
  }

  void _update() async {
    final updatedFields = <String, dynamic>{};

    _formKey.currentState!.save();

    final hasImageChanged = _foregroundImageFile != null;
    final hasTextChanged =
        _enteredDescription.text.trim() != widget.originalDescription;
    final hasTitleChanged = _enteredTitle.text.trim() != widget.originalTitle;

    if (!hasImageChanged && !hasTextChanged && !hasTitleChanged) {
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const AlertDialog(
            title: Text('Mise à jour de l\'astuce'),
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

    try {
      if (hasImageChanged) {
        final uploadedUrl = await uploadImageToFirebaseStorage(
          imageFile: _foregroundImageFile!,
          fileNumber: 1,
        );
        updatedFields['foreground_image'] = uploadedUrl;
      }

      if (hasTextChanged) {
        updatedFields['description'] = _enteredDescription.text;
      }

      if (hasTitleChanged) {
        updatedFields['titre'] = _enteredTitle.text;
      }

      await _firestore
          .collection('astuces')
          .doc(widget.astuceId)
          .update(updatedFields);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Une erreur est survenue lors de la mise à jour.',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) Navigator.of(context).pop(); // Close dialog
    }

    if (mounted) {
      Navigator.of(context).pop(); // Close screen
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Annonce mise à jour avec succès.',
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
      appBar: AppBar(title: Text('Modifier une astuce')),
      body: FutureBuilder(
        future: _loadedAstuce,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          final String image =
              snapshot.data!.foregroundImage ??
              "https://firebasestorage.googleapis.com/v0/b/depanini-3304e.firebasestorage.app/o/no_picture.png?alt=media&token=7cfab603-fc3e-4241-a9d3-6e1569aa46d7";

          return Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: snapshot.data!.titre,
                      decoration: InputDecoration(
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
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: snapshot.data!.description,
                      maxLines: 4,
                      maxLength: 150,
                      decoration: InputDecoration(
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
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: snapshot.data!.domaine,
                      readOnly: true,
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        label: Text('Domaine'),
                      ),
                    ),
                    SizedBox(height: 10),
                    UpdateImage(
                      initialImage: NetworkImage(image),
                      onPickImage: (pickedImage) {
                        _foregroundImageFile = pickedImage;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _update,
                      child: Text('Enregistrer'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
