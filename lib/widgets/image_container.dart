import 'package:flutter/material.dart';

class ImageContainer extends StatelessWidget {
  final String? imageUrl;

  const ImageContainer({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        image:
            imageUrl != null
                ? DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover, // Optional: Adjusts the image fit
                )
                : null,
      ),
      child:
          imageUrl == null
              ? Center(
                child: Icon(
                  Icons.no_photography_outlined,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
              : null,
    );
  }
}
