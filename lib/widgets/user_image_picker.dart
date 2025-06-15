import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickImage});

  final void Function(File pickedImage) onPickImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickImageFile;

  void _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(
      source: source,
      imageQuality: 100,
      maxWidth: 150,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickImageFile = File(pickedImage.path);
    });

    widget.onPickImage(_pickImageFile!);
  }

  //Lazem nefhmoha
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder:
          (ctx) => Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Picture'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              _pickImageFile != null ? FileImage(_pickImageFile!) : null,
        ),
        TextButton.icon(
          onPressed: _showImageSourceDialog,
          icon: const Icon(Icons.image),
          label: const Text('Ajouter une photo'),
        ),
      ],
    );
  }
}
