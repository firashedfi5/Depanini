import 'dart:convert';
import 'dart:io';
import 'package:depanini/constants/domains.dart';
import 'package:depanini/widgets/profil_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as dev;

final _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class ProviderAccountScreen extends StatefulWidget {
  const ProviderAccountScreen({super.key});

  @override
  State<ProviderAccountScreen> createState() => _ProviderAccountScreenState();
}

class _ProviderAccountScreenState extends State<ProviderAccountScreen> {
  // final List<Domains> _domains = Domains.values;
  // Domains? _enteredDomaine;
  // ignore: unused_field
  Domains? _selectedDomain;

  // Retreiving data from firestore
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

  // ***********************
  final _formKey = GlobalKey<FormState>();
  // Update data in the firestore
  var _enteredUserName = '';
  var _enteredPhoneNumber = '';
  var _enteredDescription = '';
  var _enteredDiplome = '';
  var _enteredExperience = '';
  final List<String> _experience = ["1-3 ans", "4-6 ans", "+6 ans"];
  // ignore: unused_field
  String? _selectedExperience = '';
  // ********************Cloudinary image upload***************************
  File? _updatedImage;
  Future<String?> uploadImageToCloudinary() async {
    final cloudName = "dgdvqiztn";
    final uploadPreset = "Profil_Images";

    final url = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

    var request =
        http.MultipartRequest("POST", Uri.parse(url))
          ..fields['upload_preset'] = uploadPreset
          ..files.add(
            await http.MultipartFile.fromPath('file', _updatedImage!.path),
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
    _formKey.currentState!.save();
    DocumentSnapshot userDoc =
        await _firestore.collection('prestataires').doc(user.uid).get();
    final currentImageUrl = userDoc['Photo de profile'];

    final finalImageUrl =
        _updatedImage != null
            ? await uploadImageToCloudinary()
            : currentImageUrl;
    await _firestore.collection('prestataires').doc(user.uid).update({
      'Nom d\'utilisateur': _enteredUserName,
      'Numéro de téléphone': _enteredPhoneNumber,
      'Photo de profile': finalImageUrl,
      // 'Domaine': _enteredDomaine!.name,
      'Description': _enteredDescription,
      'Diplôme': _enteredDiplome,
      'Experience': _enteredExperience,
    });
    dev.log('Compte mis à jour');
    if (mounted) {
      Navigator.pop(context);
    }
  }

  // ****************************

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modifier votre compte')),
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ********************************
                  SizedBox(height: 20),
                  ProfilImage(
                    onPickImage: (pickedImage) {
                      _updatedImage = pickedImage;
                    },
                    initialImage: NetworkImage(
                      snapshot.data!['Photo de profile'],
                    ),
                  ),
                  // ********************************
                  SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            initialValue: snapshot.data!['Nom d\'utilisateur'],
                            decoration: InputDecoration(
                              labelText: 'Nom d\'utilisateur',
                              hintText: 'Entrez le nom d\'utilisateur',
                              prefixIcon: Icon(Icons.account_circle_outlined),
                            ),
                            autocorrect: false,
                            enableSuggestions: false,
                            onSaved: (newValue) {
                              _enteredUserName = newValue!;
                            },
                          ),
                        ),
                        // SizedBox(height: 20),
                        // SizedBox(
                        //   width: 350,
                        //   child: DropdownButtonFormField<Domains>(
                        //     decoration: InputDecoration(
                        //       prefixIcon: Icon(Icons.domain_outlined),
                        //       labelText: 'Domaine',
                        //     ),
                        //     value: _domains.firstWhere(
                        //       (domain) =>
                        //           domain.name == snapshot.data!['Domaine'],
                        //     ),
                        //     items:
                        //         _domains.map((domain) {
                        //           return DropdownMenuItem(
                        //             value: domain,
                        //             child: Text(domain.name),
                        //           );
                        //         }).toList(),
                        //     onChanged: (value) {
                        //       setState(() {
                        //         _selectedDomain = value;
                        //       });
                        //     },
                        //     validator: (value) {
                        //       if (value == null) {
                        //         return 'Veuillez sélectionner un service';
                        //       }
                        //       return null;
                        //     },
                        //     onSaved: (newValue) {
                        //       _enteredDomaine = newValue!;
                        //     },
                        //   ),
                        // ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            initialValue: snapshot.data!['Description'],
                            decoration: InputDecoration(
                              labelText: 'Description',
                              hintText: 'Entrez le nom d\'utilisateur',
                              prefixIcon: Icon(Icons.description),
                            ),
                            autocorrect: false,
                            enableSuggestions: false,
                            onSaved: (newValue) {
                              _enteredDescription = newValue!;
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            initialValue: snapshot.data!['Diplôme'],
                            decoration: InputDecoration(
                              labelText: 'Diplôme',
                              hintText: 'Entrez le nom d\'utilisateur',
                              prefixIcon: Icon(Icons.work_outline),
                            ),
                            autocorrect: false,
                            enableSuggestions: false,
                            onSaved: (newValue) {
                              _enteredDiplome = newValue!;
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: 350,
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              label: Text('Experience'),
                              prefixIcon: Icon(Icons.timer_outlined),
                            ),
                            value: snapshot.data!['Experience'],
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
                        SizedBox(height: 20),
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            initialValue: snapshot.data!['Numéro de téléphone'],
                            decoration: InputDecoration(
                              labelText: 'Numéro de téléphone',
                              hintText: 'Entrez le numéro de téléphone',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            keyboardType: TextInputType.phone,
                            onSaved: (newValue) {
                              _enteredPhoneNumber = newValue!;
                            },
                          ),
                        ),
                        SizedBox(height: 35),
                        ElevatedButton(
                          onPressed: _update,
                          child: Text('Enregistrer'),
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
