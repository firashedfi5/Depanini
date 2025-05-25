import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/post_model.dart';
import 'package:depanini/widgets/update_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:developer' as dev;

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class EditPostScreen extends StatefulWidget {
  const EditPostScreen({
    super.key,
    required this.postId,
    required this.originalDescription,
  });

  final String postId;
  final String originalDescription;

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  DateTime? _selectedDate;
  final formatter = DateFormat.yMd();

  // String? _selectedDomain;
  final TextEditingController _enteredDescription = TextEditingController();
  // var _enteredDomaine = '';
  File? _pickImageFile_1;
  File? _pickImageFile_2;
  File? _pickImageFile_3;
  File? _pickImageFile_4;
  late List<File?> pickedImages;
  final _formKey = GlobalKey<FormState>();

  late Future<PostModel> _loadedPost;

  @override
  void initState() {
    super.initState();
    _loadedPost = _loadPost();
    pickedImages = [
      _pickImageFile_1,
      _pickImageFile_2,
      _pickImageFile_3,
      _pickImageFile_4,
    ];
  }

  // *******************GET Method************************
  Future<PostModel> _loadPost() async {
    try {
      final docSnapshot =
          await _firestore.collection('annonces').doc(widget.postId).get();

      if (!docSnapshot.exists) {
        throw Exception('Aucune annonce trouvée pour cet identifiant.');
      }

      final data = docSnapshot.data()!;

      final post = PostModel(
        postId: docSnapshot.id,
        email: data["email"],
        uid: data["uid"],
        username: data["username"],
        phoneNumber: data["phone_number"],
        profilPicture: data["profil_picture"],
        description: data["description"],
        service: data["service"],
        date: (data['date'] as Timestamp).toDate(),
        createdAt: data["createdAt"],
        image1: data["imageURL_1"],
        image2: data["imageURL_2"],
        image3: data["imageURL_3"],
        image4: data["imageURL_4"],
      );

      return post;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'annonce : $e');
    }
  }

  // ***************************Image upload**************************
  final user = _auth.currentUser!;
  Future<String?> uploadImageToFirebaseStorage({
    required File imageFile,
    required int fileNumber,
  }) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('posts_pictures')
        .child(user.uid)
        .child('${widget.postId}+${fileNumber.toString()}.jpg');
    await storageRef.putFile(imageFile);
    final imageUrl = await storageRef.getDownloadURL();
    return imageUrl;
  }
  // ******************************************

  void _update() async {
    final updatedFields = <String, dynamic>{};

    _formKey.currentState!.save();

    final hasImageChanged = pickedImages.any((image) => image != null);
    final hasTextChanged =
        _enteredDescription.text.trim() != widget.originalDescription;
    final hasDateChanged = _selectedDate != null;

    if (!hasImageChanged && !hasTextChanged && !hasDateChanged) {
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const AlertDialog(
            title: Text('Mise à jour de l\'annonce'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                  'Cela peut prendre quelques secondes...',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );

    try {
      for (int i = 0; i < pickedImages.length; i++) {
        final imageFile = pickedImages[i];
        if (imageFile != null) {
          final uploadedUrl = await uploadImageToFirebaseStorage(
            imageFile: imageFile,
            fileNumber: i + 1,
          );
          updatedFields['imageURL_${i + 1}'] = uploadedUrl;
        }
      }

      if (hasTextChanged) {
        updatedFields['description'] = _enteredDescription.text;
      }

      if (hasDateChanged) {
        updatedFields['date'] = Timestamp.fromDate(
          DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
          ),
        );
      }

      await _firestore
          .collection('annonces')
          .doc(widget.postId)
          .update(updatedFields);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Une erreur est survenue lors de la mise à jour.',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) Navigator.of(context).pop(); // Close dialog
    }

    if (mounted) {
      Navigator.of(context).pop(); // Close screen
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Annonce mise à jour avec succès.',
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
  }

  @override
  void dispose() {
    super.dispose();
    _enteredDescription.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier une annonce')),
      body: FutureBuilder<PostModel>(
        future: _loadedPost,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          final List<String> images = [
            snapshot.data!.image1 ??
                "https://firebasestorage.googleapis.com/v0/b/depanini-3304e.firebasestorage.app/o/no_picture.png?alt=media&token=7cfab603-fc3e-4241-a9d3-6e1569aa46d7",
            snapshot.data!.image2 ??
                "https://firebasestorage.googleapis.com/v0/b/depanini-3304e.firebasestorage.app/o/no_picture.png?alt=media&token=7cfab603-fc3e-4241-a9d3-6e1569aa46d7",
            snapshot.data!.image3 ??
                "https://firebasestorage.googleapis.com/v0/b/depanini-3304e.firebasestorage.app/o/no_picture.png?alt=media&token=7cfab603-fc3e-4241-a9d3-6e1569aa46d7",
            snapshot.data!.image4 ??
                "https://firebasestorage.googleapis.com/v0/b/depanini-3304e.firebasestorage.app/o/no_picture.png?alt=media&token=7cfab603-fc3e-4241-a9d3-6e1569aa46d7",
          ];

          return Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      maxLines: 4,
                      maxLength: 200,
                      initialValue: snapshot.data!.description,
                      decoration: const InputDecoration(
                        alignLabelWithHint: true,
                        label: Text('Description'),
                      ),
                      onSaved: (newValue) {
                        _enteredDescription.text = newValue!;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: snapshot.data!.service,
                      readOnly: true,
                      decoration: const InputDecoration(
                        alignLabelWithHint: true,
                        label: Text('Domaine'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate == null
                              ? DateFormat(
                                'dd/MM/yyyy',
                              ).format(snapshot.data!.date)
                              : DateFormat('dd/MM/yyyy').format(_selectedDate!),
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
                    const SizedBox(height: 10),
                    Text(
                      'Changer les photos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    // ***********Images***********************
                    SizedBox(
                      height: 220,
                      child: ListView.separated(
                        separatorBuilder: (__, _) => const SizedBox(width: 10),
                        itemCount: images.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return UpdateImage(
                            initialImage: CachedNetworkImageProvider(
                              images[index],
                              cacheKey: images[index],
                            ),
                            onPickImage: (pickedImage) {
                              pickedImages[index] = pickedImage;
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _update,
                      child: const Text('Enregistrer'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
