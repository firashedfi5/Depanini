import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateImage extends StatefulWidget {
  const UpdateImage({
    super.key,
    required this.onPickImage,
    required this.initialImage,
  });

  final ImageProvider initialImage;
  final void Function(File pickedImage) onPickImage;

  @override
  State<UpdateImage> createState() => _UpdateImageState();
}

class _UpdateImageState extends State<UpdateImage> {
  File? _pickImageFile;

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: 150,
    );

    if (pickedImage == null) return;

    setState(() {
      _pickImageFile = File(pickedImage.path);
    });

    widget.onPickImage(_pickImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 170,
          width: 170,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withAlpha(100)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
            image: DecorationImage(
              image:
                  _pickImageFile != null
                      ? FileImage(_pickImageFile!)
                      : widget.initialImage,
              // fit: BoxFit.cover,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: _pickImage,

          icon: const Icon(Icons.image),
          label: const Text('Changer la photo'),
        ),
      ],
    );
  }
}
