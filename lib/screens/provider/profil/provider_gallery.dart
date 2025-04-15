// import 'dart:io';

import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:depanini/widgets/image_container.dart';
import 'package:depanini/widgets/update_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';

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
  Future<String?> uploadProviderImageToCloudinary(File imageFile) async {
    final cloudName = "dgdvqiztn";
    final uploadPreset = "Provider_Service_Images";

    final url = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

    var request =
        http.MultipartRequest("POST", Uri.parse(url))
          ..fields['upload_preset'] = uploadPreset
          ..files.add(
            await http.MultipartFile.fromPath('file', imageFile.path),
          );

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);
      return jsonData['secure_url'];
    } else {
      dev.log("Upload failed with status: ${response.statusCode}");
      return null;
    }
  }

  // ******************************************
  void _update() async {
    DocumentSnapshot userDoc =
        await _firestore.collection('prestataires').doc(user.uid).get();
    final currentImage_1 = userDoc['Photo de travail n°1'];
    String? uploadedProviderImageUrl_1 =
        _pickImageFile_1 != null
            ? await uploadProviderImageToCloudinary(_pickImageFile_1!)
            : currentImage_1;
    // if (_pickImageFile_1 != null) {
    //   uploadedProviderImageUrl_1 = await uploadProviderImageToCloudinary(
    //     _pickImageFile_1!,
    //   );
    // } else {
    //   uploadedProviderImageUrl_1 = _currentImage_1;
    // }

    await _firestore.collection('prestataires').doc(user.uid).update({
      'Photo de travail n°1': uploadedProviderImageUrl_1,
      // 'Photo de travail n°2': _enteredPhoneNumber,
      // 'Photo de travail n°3': _enteredPhoneNumber,
      // 'Photo de travail n°4': _enteredPhoneNumber,
    });
    dev.log('Photo de prestation mis à jour');
    if (mounted) {
      Navigator.pop(context);
    }
  }

  // ****************************

  late Future<Map<String, dynamic>?> userData;

  final user = _auth.currentUser!;
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
          List<dynamic> images = [
            snapshot.data!['Photo de travail n°1'] ?? '',
            snapshot.data!['Photo de travail n°2'] ?? '',
            snapshot.data!['Photo de travail n°3'] ?? '',
            snapshot.data!['Photo de travail n°4'] ?? '',
          ];
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.8,
                      ),
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return UpdateImage(
                          onPickImage: (pickedImage) {
                            pickedImages[index] = pickedImage;
                            // dev.log(index.toString());
                          },
                          initialImage: NetworkImage(images[index]),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _update,
                    child: Text('Enregistrer'),
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
