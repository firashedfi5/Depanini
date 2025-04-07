import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class ProviderGallery extends StatefulWidget {
  const ProviderGallery({super.key});

  @override
  State<ProviderGallery> createState() => _ProviderGalleryState();
}

class _ProviderGalleryState extends State<ProviderGallery> {
  File? _pickImageFile_1;
  File? _pickImageFile_2;
  File? _pickImageFile_3;
  File? _pickImageFile_4;
  late Future<Map<String, dynamic>?> userData;
  @override
  void initState() {
    super.initState();
    userData = getUserData();
  }

  final user = _auth.currentUser!;
  Future<Map<String, dynamic>?> getUserData() async {
    // if (user == null) return null; // No user logged in

    try {
      DocumentSnapshot doc =
          await _firestore.collection("prestataires").doc(user.uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>; // Convert document to map
      } else {
        return null; // Document does not exist
      }
    } catch (e) {
      // print("Error retrieving document: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modifier votre gallerie')),
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
            return Center(child: Text("Aucune donnée trouvée"));
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                InkWell(
                  onTap: () async {
                    final pickedImage = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 50,
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
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      image:
                          snapshot.data!['Photo de travail n°1'] != null
                              ? DecorationImage(
                                image: NetworkImage(
                                  snapshot
                                      .data!['Photo de travail n°1']
                                      .image1!,
                                ),
                                fit:
                                    BoxFit
                                        .cover, // Optional: Adjusts the image fit
                              )
                              : null,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    // _pickImageFile_1 != null
                    //     ? DecorationImage(
                    //       fit: BoxFit.cover,
                    //       image: FileImage(_pickImageFile_1!),
                    //     )
                    //     : null,
                    //   borderRadius: BorderRadius.circular(15),
                    // ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // if (_pickImageFile_1 == null)
                        // Icon(
                        //   Icons.add_a_photo,
                        //   size: 50,
                        //   color:
                        //       Theme.of(
                        //         context,
                        //       ).colorScheme.primary,
                        // ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 7),
                InkWell(
                  onTap: () async {
                    final pickedImage = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 50,
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
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      image:
                          snapshot.data!['Photo de travail n°2'] != null
                              ? DecorationImage(
                                image: NetworkImage(
                                  snapshot.data!['Photo de travail n°1'],
                                ),
                                fit:
                                    BoxFit
                                        .cover, // Optional: Adjusts the image fit
                              )
                              : null,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // if (_pickImageFile_2 == null)
                        // Icon(
                        //   Icons.add_a_photo,
                        //   size: 50,
                        //   color:
                        //       Theme.of(
                        //         context,
                        //       ).colorScheme.primary,
                        // ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 7),
                InkWell(
                  onTap: () async {
                    final pickedImage = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 50,
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
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      image:
                          snapshot.data!['Photo de travail n°3'] != null
                              ? DecorationImage(
                                image: NetworkImage(
                                  snapshot
                                      .data!['Photo de travail n°3']
                                      .image3!,
                                ),
                                fit:
                                    BoxFit
                                        .cover, // Optional: Adjusts the image fit
                              )
                              : null,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // if (_pickImageFile_3 == null)
                        //   Icon(
                        //     Icons.add_a_photo,
                        //     size: 50,
                        //     color:
                        //         Theme.of(
                        //           context,
                        //         ).colorScheme.primary,
                        //   ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 7),
                InkWell(
                  onTap: () async {
                    final pickedImage = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 50,
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
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      image:
                          snapshot.data!['Photo de travail n°4'] != null
                              ? DecorationImage(
                                image: NetworkImage(
                                  snapshot.data!['Photo de travail n°4'],
                                ),
                                fit:
                                    BoxFit
                                        .cover, // Optional: Adjusts the image fit
                              )
                              : null,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // if (_pickImageFile_4 == null)
                        //   Icon(
                        //     Icons.add_a_photo,
                        //     size: 50,
                        //     color:
                        //         Theme.of(
                        //           context,
                        //         ).colorScheme.primary,
                        //   ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
