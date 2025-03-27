import 'package:flutter/material.dart';

class ImageContainer extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double width;

  const ImageContainer({
    super.key,
    this.imageUrl,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.onSecondaryContainer,
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
