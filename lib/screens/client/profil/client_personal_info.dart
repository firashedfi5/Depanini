import 'dart:io';
import 'package:depanini/models/client_account_model.dart';
import 'package:depanini/widgets/profil_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer' as dev;

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;
final _storage = FirebaseStorage.instance;

class ClientPersonalInfo extends StatefulWidget {
  const ClientPersonalInfo({super.key});

  @override
  State<ClientPersonalInfo> createState() => _ClientPersonalInfoState();
}

class _ClientPersonalInfoState extends State<ClientPersonalInfo> {
  String? originalUsername;
  String? originalPhoneNumber;

  late Future<Map<String, dynamic>?> userData;

  @override
  void initState() {
    super.initState();
    userData = getUserData();
  }

  final user = _auth.currentUser!;

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection("clients").doc(user.uid).get();
      if (doc.exists) {
        final client = ClientModel.fromSnapshot(
          doc as DocumentSnapshot<Map<String, dynamic>>,
        );
        setState(() {
          originalUsername = client.username ?? '';
          originalPhoneNumber = client.phoneNumber ?? '';
        });
        dev.log('Client data: ${client.username}');
        dev.log('Client data: ${client.phoneNumber}');
        return doc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      dev.log("Error retrieving document: $e");
      return null;
    }
  }

  // ***********************
  final _formKey = GlobalKey<FormState>();
  // Update data in the firestore
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  // ********************Image upload***************************
  File? _updatedImage;
  Future<String?> uploadImageToFirebaseStorage() async {
    final storageRef = _storage
        .ref()
        .child('users_profile_pictures')
        .child('clients_profile_pictures')
        .child('${user.uid}.jpg');
    await storageRef.putFile(_updatedImage!);
    final imageUrl = await storageRef.getDownloadURL();
    return imageUrl;
  }

  void _update() async {
    _formKey.currentState!.save();

    final hasImageChanged = _updatedImage != null;
    final hasUsernameChanged =
        _userNameController.text.trim() != originalUsername;
    final hasPhoneNumberChanged =
        _phoneNumberController.text.trim() != originalPhoneNumber;

    if (hasImageChanged || hasUsernameChanged || hasPhoneNumberChanged) {
      DocumentSnapshot userDoc =
          await _firestore.collection('clients').doc(user.uid).get();
      final currentImageUrl = userDoc['Photo de profile'];

      final finalImageUrl =
          _updatedImage != null
              ? await uploadImageToFirebaseStorage()
              : currentImageUrl;
      await _firestore.collection('clients').doc(user.uid).update({
        'Nom d\'utilisateur': _userNameController.text,
        'Numéro de téléphone': _phoneNumberController.text,
        'Photo de profile': finalImageUrl,
      });
      final postRef =
          await _firestore
              .collection('annonces')
              .where('uid', isEqualTo: user.uid)
              .get();

      for (var doc in postRef.docs) {
        await doc.reference.update({
          'username': _userNameController.text,
          'phone_number': _phoneNumberController.text,
          'profil_picture': finalImageUrl,
        });
      }

      final rdvRef =
          await _firestore
              .collection('rdvs')
              .where('client_uid', isEqualTo: user.uid)
              .get();

      for (var doc in rdvRef.docs) {
        await doc.reference.update({
          'client_username': _userNameController.text,
          'client_profile_picture': finalImageUrl,
        });
      }

      dev.log('Compte mis à jour');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Compte mise à jour avec succès.',
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
    } else {
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
  }

  // ****************************

  @override
  void dispose() {
    super.dispose();
    _userNameController.dispose();
    _phoneNumberController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier votre compte')),
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
          return SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 50),
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
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            initialValue: snapshot.data!['Nom d\'utilisateur'],
                            decoration: const InputDecoration(
                              labelText: 'Nom d\'utilisateur',
                              hintText: 'Entrez le nom d\'utilisateur',
                              prefixIcon: Icon(Icons.account_circle_outlined),
                            ),
                            autocorrect: false,
                            enableSuggestions: false,
                            onSaved: (newValue) {
                              _userNameController.text = newValue!;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            initialValue: snapshot.data!['Numéro de téléphone'],
                            decoration: const InputDecoration(
                              labelText: 'Numéro de téléphone',
                              hintText: 'Entrez le numéro de téléphone',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            keyboardType: TextInputType.phone,
                            onSaved: (newValue) {
                              _phoneNumberController.text = newValue!;
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _update,
                          child: const Text('Enregistrer'),
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
