import 'dart:io';
import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/widgets/update_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class ProviderGallery extends StatefulWidget {
  const ProviderGallery({super.key});

  @override
  State<ProviderGallery> createState() => _ProviderGalleryState();
}

class _ProviderGalleryState extends State<ProviderGallery> {
  final user = _auth.currentUser!;
  File? _pickImageFile_1;
  File? _pickImageFile_2;
  File? _pickImageFile_3;
  File? _pickImageFile_4;
  late List<File?> pickedImages;

  @override
  void initState() {
    super.initState();
    userData = getUserData();
    pickedImages = [
      _pickImageFile_1,
      _pickImageFile_2,
      _pickImageFile_3,
      _pickImageFile_4,
    ];
  }

  // ******************************************
  Future<String?> uploadProviderImageToFirebaseStorage({
    required File imageFile,
    required int fileNumber,
  }) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('prestataires_portfolio_pictures')
        .child('${user.uid}+$fileNumber.jpg');
    await storageRef.putFile(imageFile);
    final imageUrl = await storageRef.getDownloadURL();
    // dev.log(imageUrl);
    return imageUrl;
  }

  // ******************************************
  void _showUploadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => const AlertDialog(
            title: Text('Envoi en cours...'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                  'Veuillez patienter pendant que vos photos sont mises à jour...',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );
  }

  // ******************************************
  Future<void> _update() async {
    final updatedFields = <String, dynamic>{};
    final hasImageToUpload = pickedImages.any((image) => image != null);

    if (!hasImageToUpload) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veuillez changer au moins une photo pour enregistrer.',
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

    // Show loading dialog once before uploading starts
    _showUploadingDialog();

    try {
      for (int i = 0; i < pickedImages.length; i++) {
        final imageFile = pickedImages[i];
        if (imageFile != null) {
          final uploadedUrl = await uploadProviderImageToFirebaseStorage(
            imageFile: imageFile,
            fileNumber: i + 1,
          );
          updatedFields['Photo de travail n°${i + 1}'] = uploadedUrl;
        }
      }

      if (updatedFields.isNotEmpty) {
        await _firestore
            .collection('prestataires')
            .doc(user.uid)
            .update(updatedFields);
      }
    } catch (e) {
      dev.log('Erreur lors de l\'upload: $e');
    } finally {
      if (mounted) Navigator.of(context).pop(); // Hide dialog once
    }

    if (mounted) {
      Navigator.pop(context); // Close screen
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Photos mises à jour avec succès',
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

  // ****************************

  late Future<Map<String, dynamic>?> userData;

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection("prestataires").doc(user.uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>; // Convert document to map
      } else {
        return null; // Document does not exist
      }
    } catch (e) {
      dev.log("Error retrieving document: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier votre gallerie')),
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
          List<dynamic> images = [
            snapshot.data!['Photo de travail n°1'] ?? '',
            snapshot.data!['Photo de travail n°2'] ?? '',
            snapshot.data!['Photo de travail n°3'] ?? '',
            snapshot.data!['Photo de travail n°4'] ?? '',
          ];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              spacing: 20,
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.8,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return UpdateImage(
                        onPickImage: (pickedImage) {
                          pickedImages[index] = pickedImage;
                        },
                        initialImage:
                            images[index].isNotEmpty
                                ? CachedNetworkImageProvider(
                                  images[index],
                                  cacheKey: images[index],
                                )
                                : const CachedNetworkImageProvider(
                                  'https://firebasestorage.googleapis.com/v0/b/depanini-3304e.firebasestorage.app/o/no_picture.png?alt=media&token=7cfab603-fc3e-4241-a9d3-6e1569aa46d7',
                                  cacheKey:
                                      'https://firebasestorage.googleapis.com/v0/b/depanini-3304e.firebasestorage.app/o/no_picture.png?alt=media&token=7cfab603-fc3e-4241-a9d3-6e1569aa46d7',
                                ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _update,
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
