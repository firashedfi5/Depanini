import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostImage extends StatelessWidget {
  final File? pickedImageFile;
  final ValueChanged<File?> onImagePicked;

  const PostImage({
    super.key,
    required this.pickedImageFile,
    required this.onImagePicked,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final pickedImage = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 50,
          maxWidth: 150,
        );
        if (pickedImage == null) {
          return;
        }
        onImagePicked(File(pickedImage.path));
      },
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          image:
              pickedImageFile != null
                  ? DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(pickedImageFile!),
                  )
                  : null,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (pickedImageFile == null)
              Icon(
                Icons.add_a_photo,
                size: 50,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
