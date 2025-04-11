import 'package:depanini/constants/domains.dart';
import 'package:depanini/providers/user_information.dart';
import 'package:depanini/screens/auth/verify_email_screen.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as dev;

final _firebase = FirebaseAuth.instance;

class ProviderDescription extends ConsumerStatefulWidget {
  const ProviderDescription({super.key});

  @override
  ConsumerState<ProviderDescription> createState() =>
      _ProviderDescriptionState();
}

class _ProviderDescriptionState extends ConsumerState<ProviderDescription> {
  // **********List***********
  final List<Domains> _domains = Domains.values;

  Domains? _selectedDomain;
  // ***********************

  // *********Image************
  File? _pickImageFile_1;
  File? _pickImageFile_2;
  File? _pickImageFile_3;
  File? _pickImageFile_4;
  // ************************
  // ************Form*************
  var _enteredDescription = '';
  Domains? _enteredDomaine;
  var _enteredDiplome = '';
  var _enteredExperience = '';
  final _formKey = GlobalKey<FormState>();
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
      dev.log("Upload failed with status: ${response.statusCode}");
      return null;
    }
  }

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

  // **********************************************
  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    final userInfo = ref.watch(userInformationProvdier);
    // **************Firabese Auth********************
    try {
      final userCredential = await _firebase.createUserWithEmailAndPassword(
        email: userInfo.email!,
        password: userInfo.password!,
      );
      // ******************************
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Compte créé avec succès! Un email de vérification vous a été envoyé.',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      var uploadedImageUrl = await uploadImageToCloudinary();

      // Upload service images if they exist
      String? uploadedProviderImageUrl_1;
      if (_pickImageFile_1 != null) {
        uploadedProviderImageUrl_1 = await uploadProviderImageToCloudinary(
          _pickImageFile_1!,
        );
      }
      String? uploadedProviderImageUrl_2;
      if (_pickImageFile_2 != null) {
        uploadedProviderImageUrl_2 = await uploadProviderImageToCloudinary(
          _pickImageFile_2!,
        );
      }
      String? uploadedProviderImageUrl_3;
      if (_pickImageFile_3 != null) {
        uploadedProviderImageUrl_3 = await uploadProviderImageToCloudinary(
          _pickImageFile_3!,
        );
      }
      String? uploadedProviderImageUrl_4;
      if (_pickImageFile_4 != null) {
        uploadedProviderImageUrl_4 = await uploadProviderImageToCloudinary(
          _pickImageFile_4!,
        );
      }

      // *****************Firestore*******************
      await FirebaseFirestore.instance
          .collection('prestataires')
          .doc(userCredential.user!.uid)
          .set({
            'Uid': userCredential.user!.uid,
            'Nom d\'utilisateur': userInfo.userName,
            'Rôle': userInfo.role,
            'Numéro de téléphone': userInfo.phoneNumber,
            'Email': userInfo.email,
            'Description': _enteredDescription,
            'Domaine': _enteredDomaine!.name,
            'Diplôme': _enteredDiplome,
            'Experience': _enteredExperience,
            'Photo de profile': uploadedImageUrl,
            'Photo de travail n°1': uploadedProviderImageUrl_1,
            'Photo de travail n°2': uploadedProviderImageUrl_2,
            'Photo de travail n°3': uploadedProviderImageUrl_3,
            'Photo de travail n°4': uploadedProviderImageUrl_4,
            'averageRating': 0,
          });
      // ************************************
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VerifyEmailScreen()),
        );
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cet e-mail est déjà utilisé. Veuillez vous connecter ou utiliser un autre e-mail.',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Une erreur est survenue. Veuillez réessayer.',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ********************************
  final List<String> _experience = ["1-3 ans", "4-6 ans", "+6 ans"];
  String? _selectedExperience;
  @override
  Widget build(BuildContext context) {
    // final userInfo = ref.watch(userInformationProvdier);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                textAlign: TextAlign.center,
                'Finalisez la création de votre compte',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Form(
                  key: _formKey,
                  child: SizedBox(
                    height: 600,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Description',
                              prefixIcon: Icon(Icons.description_outlined),
                            ),
                            autocorrect: false,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Veuillez entrer votre nom d\'utilisateur';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredDescription = newValue!;
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: 350,
                          child: DropdownButtonFormField<Domains>(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.domain_outlined),
                              labelText: 'Domaine',
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
                                return 'Veuillez sélectionner un domaine';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredDomaine = newValue!;
                            },
                          ),
                          // ******************
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            // initialValue: userInfo.userName,
                            decoration: InputDecoration(
                              labelText: 'Diplôme',
                              hintText: 'Entrez votre diplôme',
                              prefixIcon: Icon(Icons.work_outline),
                            ),
                            autocorrect: false,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Veuillez entrer votre nom d\'utilisateur';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredDiplome = newValue!;
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: 350,
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              label: Text('Experience'),
                              prefixIcon: Icon(Icons.timer_outlined),
                            ),
                            value: _selectedExperience,
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
                        SizedBox(height: 10),
                        Text(
                          'Ajoutez des photos de vos prestations',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        SizedBox(height: 5),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () async {
                                  final pickedImage = await ImagePicker()
                                      .pickImage(
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
                                  height: 170,
                                  width: 170,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      100,
                                      113,
                                      109,
                                      109,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    image:
                                        _pickImageFile_1 != null
                                            ? DecorationImage(
                                              fit: BoxFit.cover,
                                              image: FileImage(
                                                _pickImageFile_1!,
                                              ),
                                            )
                                            : null,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_pickImageFile_1 == null)
                                        Icon(Icons.add_a_photo, size: 60),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              InkWell(
                                onTap: () async {
                                  final pickedImage = await ImagePicker()
                                      .pickImage(
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
                                  height: 170,
                                  width: 170,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      100,
                                      113,
                                      109,
                                      109,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    image:
                                        _pickImageFile_2 != null
                                            ? DecorationImage(
                                              fit: BoxFit.cover,
                                              image: FileImage(
                                                _pickImageFile_2!,
                                              ),
                                            )
                                            : null,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_pickImageFile_2 == null)
                                        Icon(Icons.add_a_photo, size: 60),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              InkWell(
                                onTap: () async {
                                  final pickedImage = await ImagePicker()
                                      .pickImage(
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
                                  height: 170,
                                  width: 170,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      100,
                                      113,
                                      109,
                                      109,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    image:
                                        _pickImageFile_3 != null
                                            ? DecorationImage(
                                              fit: BoxFit.cover,
                                              image: FileImage(
                                                _pickImageFile_3!,
                                              ),
                                            )
                                            : null,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_pickImageFile_3 == null)
                                        Icon(Icons.add_a_photo, size: 60),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              InkWell(
                                onTap: () async {
                                  final pickedImage = await ImagePicker()
                                      .pickImage(
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
                                  height: 170,
                                  width: 170,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      100,
                                      113,
                                      109,
                                      109,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    image:
                                        _pickImageFile_4 != null
                                            ? DecorationImage(
                                              fit: BoxFit.cover,
                                              image: FileImage(
                                                _pickImageFile_4!,
                                              ),
                                            )
                                            : null,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_pickImageFile_4 == null)
                                        Icon(Icons.add_a_photo, size: 60),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                        SizedBox(
                          width: 350,
                          child: ElevatedButton(
                            onPressed: _submit,
                            child: Text('Enregistrer'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
