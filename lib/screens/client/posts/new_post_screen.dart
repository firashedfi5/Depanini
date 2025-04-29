import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/constants/domains.dart';
import 'package:depanini/widgets/post_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as dev;

import 'package:http/http.dart' as http;

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

final _auth = FirebaseAuth.instance;

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  // **************Cloudinary******************
  Future<String?> uploadAnnoncesImageToCloudinary(File imageFile) async {
    final cloudName = "dgdvqiztn";
    final uploadPreset = "Post_Images";

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

  final List<Domains> _domains = Domains.values;

  Domains? _selectedDomain;
  var _enteredDescription = '';
  Domains? _enteredDomaine;
  File? _pickImageFile_1;
  File? _pickImageFile_2;
  File? _pickImageFile_3;
  File? _pickImageFile_4;
  final _formKey = GlobalKey<FormState>();
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
      // Upload service images if they exist
      String? uploadedPostImageUrl_1;
      if (_pickImageFile_1 != null) {
        uploadedPostImageUrl_1 = await uploadAnnoncesImageToCloudinary(
          _pickImageFile_1!,
        );
      }
      String? uploadedPostImageUrl_2;
      if (_pickImageFile_2 != null) {
        uploadedPostImageUrl_2 = await uploadAnnoncesImageToCloudinary(
          _pickImageFile_2!,
        );
      }
      String? uploadedPostImageUrl_3;
      if (_pickImageFile_3 != null) {
        uploadedPostImageUrl_3 = await uploadAnnoncesImageToCloudinary(
          _pickImageFile_3!,
        );
      }
      String? uploadedPostImageUrl_4;
      if (_pickImageFile_4 != null) {
        uploadedPostImageUrl_4 = await uploadAnnoncesImageToCloudinary(
          _pickImageFile_4!,
        );
      }
      // **********Fetch Data From Firestore**********
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
      // ***********HTTP Request**************
      final url = Uri.http(
        '10.0.2.2:3300',
        'ajouter-annonces',
      ); // Virtual Device: 10.0.2.2 - Actual Device: 192.168.1.11 (ipconfig -> IPv4)
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'uid': _auth.currentUser!.uid,
          'email': email,
          'username': username,
          'phone_number': phoneNumber,
          'profil_picture': profilPictureURL,
          'description': _enteredDescription,
          'service': _enteredDomaine!.name,
          'date': _selectedDate == null ? '' : formatter.format(_selectedDate!),
          'imageURL_1': uploadedPostImageUrl_1,
          'imageURL_2': uploadedPostImageUrl_2,
          'imageURL_3': uploadedPostImageUrl_3,
          'imageURL_4': uploadedPostImageUrl_4,
        }),
      );
    }
  }

  DateTime? _selectedDate;
  final formatter = DateFormat.yMd();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajouter une annonce')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
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
                      _enteredDescription = value!;
                    },
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<Domains>(
                    decoration: InputDecoration(
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
                  SizedBox(height: 20),
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
                  SizedBox(height: 10),
                  Text(
                    'Ajouter des photos',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  SizedBox(height: 10),
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
                        SizedBox(width: 7),
                        PostImage(
                          pickedImageFile: _pickImageFile_2,
                          onImagePicked: (file) {
                            setState(() {
                              _pickImageFile_2 = file;
                            });
                          },
                        ),
                        SizedBox(width: 7),
                        PostImage(
                          pickedImageFile: _pickImageFile_3,
                          onImagePicked: (file) {
                            setState(() {
                              _pickImageFile_3 = file;
                            });
                          },
                        ),
                        SizedBox(width: 7),
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
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _savePost,
                    // _savePost,
                    child: Text('Ajouter'),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
