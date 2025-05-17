import 'package:depanini/screens/auth/provider_description.dart';
import 'package:depanini/screens/auth/verify_email_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:depanini/providers/user_information.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firebase = FirebaseAuth.instance;

class ChoosingScreen extends ConsumerStatefulWidget {
  const ChoosingScreen({super.key});

  @override
  ConsumerState<ChoosingScreen> createState() => _ChoosingScreenState();
}

class _ChoosingScreenState extends ConsumerState<ChoosingScreen> {
  String _enetredRole = '';

  // ********************Image upload***************************
  Future<String?> uploadImageToFirebaseStorage(String userUid) async {
    final userInfo = ref.watch(userInformationProvdier);
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('users_profile_pictures')
        .child('clients_profile_pictures')
        .child('$userUid.jpg');
    await storageRef.putFile(userInfo.profilImage!);
    final imageUrl = await storageRef.getDownloadURL();
    return imageUrl;
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

                  // **************Firabese Auth********************
                  final userCredential = await _firebase
                      .createUserWithEmailAndPassword(
                        email: userInfo.email!,
                        password: userInfo.password!,
                      );
                  // ***********************************
                  var uploadedImageUrl = await uploadImageToFirebaseStorage(
                    userCredential.user!.uid,
                  );
                  // ***********************************
                  if (context.mounted) {
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
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                    );
                  }
                  // *****************Firestore*******************
                  await FirebaseFirestore.instance
                      .collection('clients')
                      .doc(userCredential.user!.uid)
                      .set({
                        'Nom d\'utilisateur': userInfo.username,
                        'Rôle': _enetredRole,
                        'Numéro de téléphone': userInfo.phoneNumber,
                        'Email': userInfo.email,
                        'Photo de profile': uploadedImageUrl,
                        'Localisation': userInfo.location!.address,
                        'Latitude&Longitude': GeoPoint(
                          userInfo.location!.latitude,
                          userInfo.location!.longitude,
                        ),
                        'Uid': userCredential.user!.uid,
                        'Inscrit Le': DateTime.now(),
                        'Status': 'Activé',
                      });
                  // ********************************************
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerifyEmailScreen(),
                      ),
                    );
                  }
                } on FirebaseAuthException catch (error) {
                  if (error.code == 'email-already-in-use') {
                    if (context.mounted) {
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
                          backgroundColor: const Color(0xffb3261e),
                        ),
                      );
                    }
                  } else {
                    if (context.mounted) {
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
                          backgroundColor: const Color(0xffb3261e),
                        ),
                      );
                    }
                  }
                }
              },
              child: Card(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromARGB(255, 43, 43, 49)
                        : const Color.fromARGB(255, 236, 229, 243),
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
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromARGB(255, 43, 43, 49)
                        : const Color.fromARGB(255, 236, 229, 243),
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
