import 'dart:convert';
import 'dart:io';
import 'package:depanini/widgets/profil_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as dev;

final _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
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
          await _firestore.collection("clients").doc(user.uid).get();
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
  void _updateUsernameAnnonces() async {
    final url = Uri.http(
      '10.0.2.2:3300',
      'changer-username-annonces/${_auth.currentUser!.uid}',
    ); // Virtual Device: 10.0.2.2 - Actual Device: 192.168.1.11 (ipconfig -> IPv4)
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': _enteredUserName}),
    );
    final responseData = json.decode(response.body);
    dev.log('${responseData['message']}, ${response.statusCode}');
  }

  void _updateProfilPictureAnnonces(String finalImageUrl) async {
    final url = Uri.http(
      '10.0.2.2:3300',
      'changer-profilPicture-annonces/${_auth.currentUser!.uid}',
    ); // Virtual Device: 10.0.2.2 - Actual Device: 192.168.1.11 (ipconfig -> IPv4)
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'profile_picture': finalImageUrl}),
    );
    final responseData = json.decode(response.body);
    dev.log('${responseData['message']}, ${response.statusCode}');
  }

  void _updatePhoneNumberAnnonces() async {
    final url = Uri.http(
      '10.0.2.2:3300',
      'changer-phoneNumber-annonces/${_auth.currentUser!.uid}',
    ); // Virtual Device: 10.0.2.2 - Actual Device: 192.168.1.11 (ipconfig -> IPv4)
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'phone_number': _enteredPhoneNumber}),
    );
    final responseData = json.decode(response.body);
    dev.log('${responseData['message']}, ${response.statusCode}');
  }

  // ******************************************
  void _update() async {
    _formKey.currentState!.save();
    DocumentSnapshot userDoc =
        await _firestore.collection('clients').doc(user.uid).get();
    final currentImageUrl = userDoc['Photo de profile'];

    final finalImageUrl =
        _updatedImage != null
            ? await uploadImageToCloudinary()
            : currentImageUrl;
    await _firestore.collection('clients').doc(user.uid).update({
      'Nom d\'utilisateur': _enteredUserName,
      'Numéro de téléphone': _enteredPhoneNumber,
      'Photo de profile': finalImageUrl,
    });
    _updateUsernameAnnonces();
    _updateProfilPictureAnnonces(finalImageUrl);
    _updatePhoneNumberAnnonces();
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
                  SizedBox(height: 20),
                  // ********************************
                  ProfilImage(
                    onPickImage: (pickedImage) {
                      _updatedImage = pickedImage;
                    },
                    initialImage: NetworkImage(
                      snapshot.data!['Photo de profile'],
                    ),
                  ),
                  // ********************************
                  SizedBox(height: 80),
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
                        SizedBox(height: 80),
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
