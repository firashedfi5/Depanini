import 'dart:developer' as dev;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/constants/domains.dart';
import 'package:depanini/widgets/post_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final user = _auth.currentUser!;
  final uuid = Uuid();
  late String postId;
  @override
  void initState() {
    super.initState();
    postId = uuid.v4();
  }

  // **************Image upload******************
  Future<String?> uploadImageToFirebaseStorage(
    File imageFile,
    int fileNumber,
  ) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('posts_pictures')
        .child(user.uid)
        .child('$postId+${fileNumber.toString()}.jpg');
    await storageRef.putFile(imageFile);
    final imageUrl = await storageRef.getDownloadURL();
    return imageUrl;
  }
  // ******************************************

  final List<Domains> _domains = Domains.values;

  Domains? _selectedDomain;
  final TextEditingController _enteredDescription = TextEditingController();
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
      dev.log(_selectedDate.toString());
      if (mounted) {
        // Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Annonce ajoutée avec succès.',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      // Upload service images if they exist
      String? uploadedPostImageUrl_1;
      if (_pickImageFile_1 != null) {
        uploadedPostImageUrl_1 = await uploadImageToFirebaseStorage(
          _pickImageFile_1!,
          1,
        );
      }
      String? uploadedPostImageUrl_2;
      if (_pickImageFile_2 != null) {
        uploadedPostImageUrl_2 = await uploadImageToFirebaseStorage(
          _pickImageFile_2!,
          2,
        );
      }
      String? uploadedPostImageUrl_3;
      if (_pickImageFile_3 != null) {
        uploadedPostImageUrl_3 = await uploadImageToFirebaseStorage(
          _pickImageFile_3!,
          3,
        );
      }
      String? uploadedPostImageUrl_4;
      if (_pickImageFile_4 != null) {
        uploadedPostImageUrl_4 = await uploadImageToFirebaseStorage(
          _pickImageFile_4!,
          4,
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
      // ***********Storing data in Firestore**************
      _firestore.collection('annonces').doc(postId).set({
        "post_id": postId,
        'uid': _auth.currentUser!.uid,
        'email': email,
        'username': username,
        'phone_number': phoneNumber,
        'profil_picture': profilPictureURL,
        'description': _enteredDescription.text,
        'service': _enteredDomaine!.name,
        // 'date': _selectedDate == null ? '' : formatter.format(_selectedDate!),
        'date': Timestamp.fromDate(
          DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
          ),
        ),
        'imageURL_1': uploadedPostImageUrl_1,
        'imageURL_2': uploadedPostImageUrl_2,
        'imageURL_3': uploadedPostImageUrl_3,
        'imageURL_4': uploadedPostImageUrl_4,
        'createdAt': Timestamp.now(),
      });
    }
  }

  DateTime? _selectedDate;
  final formatter = DateFormat.yMd();

  @override
  void dispose() {
    super.dispose();
    _enteredDescription.dispose();
  }

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
                    controller: _enteredDescription,
                    maxLines: 4,
                    maxLength: 150,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      label: Text('Description'),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre description';
                      }
                      if (value.trim().length <= 15 ||
                          value.trim().length > 150) {
                        return 'La description doit contenir entre 15 et 150 caractères';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredDescription.text = value!;
                    },
                  ),
                  SizedBox(height: 10),
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
                  SizedBox(height: 10),
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
                    style: Theme.of(context).textTheme.titleMedium,
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
