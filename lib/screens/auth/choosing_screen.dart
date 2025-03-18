import 'package:depanini/screens/auth/provider_description.dart';
import 'package:depanini/screens/auth/verify_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:depanini/providers/user_information.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final _firebase = FirebaseAuth.instance;

class ChoosingScreen extends ConsumerStatefulWidget {
  const ChoosingScreen({super.key});

  @override
  ConsumerState<ChoosingScreen> createState() => _ChoosingScreenState();
}

class _ChoosingScreenState extends ConsumerState<ChoosingScreen> {
  String _enetredRole = '';

  // ********************Cloudinary image upload***************************
  Future<String?> uploadImageToCloudinary() async {
    final userInfo = ref.watch(userInformationProvdier);

    final cloudName = "dgdvqiztn";
    final uploadPreset = "Profil_Images";

    final url = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

    var request =
        http.MultipartRequest("POST", Uri.parse(url))
          ..fields['upload_preset'] = uploadPreset
          ..files.add(
            await http.MultipartFile.fromPath(
              'file',
              userInfo.profilImage!.path,
            ),
          );

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);
      return jsonData['secure_url'];
    } else {
      print("Upload failed with status: ${response.statusCode}");
      return null;
    }
  }

  // **********************************************

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              textAlign: TextAlign.center,
              'Choisissez votre rôle',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            InkWell(
              splashColor: Theme.of(context).splashColor,
              splashFactory: Theme.of(context).splashFactory,
              borderRadius: BorderRadius.circular(15),
              onTap: () async {
                try {
                  final userInfo = ref.watch(userInformationProvdier);
                  _enetredRole = 'Client';
                  ref
                      .read(userInformationProvdier.notifier)
                      .updateRole(_enetredRole);

                  // **************Cloudinary********************
                  var uploadedImageUrl = await uploadImageToCloudinary();
                  // **************Firabese Auth********************
                  final userCredential = await _firebase
                      .createUserWithEmailAndPassword(
                        email: userInfo.email!,
                        password: userInfo.password!,
                      );
                  // ***********************************
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Compte créé avec succès! Un email de vérification vous a été envoyé.',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // *****************Firestore*******************
                  await FirebaseFirestore.instance
                      .collection('clients')
                      .doc(userCredential.user!.uid)
                      .set({
                        'Nom d\'utilisateur': userInfo.userName,
                        'Rôle': _enetredRole,
                        'Numéro de téléphone': userInfo.phoneNumber,
                        'Email': userInfo.email,
                        'Photo de profile': uploadedImageUrl,
                      });
                  // ********************************************
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerifyEmailScreen(),
                    ),
                  );
                } on FirebaseAuthException catch (error) {
                  if (error.code == 'email-already-in-use') {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Cet e-mail est déjà utilisé. Veuillez vous connecter ou utiliser un autre e-mail.',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Une erreur est survenue. Veuillez réessayer.',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Card(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/icons/customer-service.png',
                      width: 200,
                      scale: 3.5,
                    ),
                    Text(
                      'Client',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                _enetredRole = 'Prestataire';
                ref
                    .read(userInformationProvdier.notifier)
                    .updateRole(_enetredRole);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (contexte) => ProviderDescription(),
                  ),
                );
              },
              child: Card(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/icons/service.png',
                      width: 200,
                      scale: 3.5,
                    ),
                    Text(
                      'Prestataire',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
