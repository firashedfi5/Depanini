import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilImage extends StatefulWidget {
  const ProfilImage({
    super.key,
    required this.onPickImage,
    required this.initialImage,
  });

  final NetworkImage initialImage;

  final void Function(File pickedImage) onPickImage;

  @override
  State<ProfilImage> createState() => _ProfilImageState();
}

class _ProfilImageState extends State<ProfilImage> {
  File? _pickImageFile;

  void _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
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
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Picture'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Choose from Gallery'),
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
          radius: 75,
          backgroundColor: Colors.grey,
          foregroundImage:
              _pickImageFile != null
                  ? FileImage(_pickImageFile!)
                  : widget.initialImage,
        ),
        SizedBox(height: 10),
        TextButton.icon(
          onPressed: _showImageSourceDialog,
          icon: Icon(Icons.image),
          label: Text('Changer la photo'),
        ),
      ],
    );
  }
}
