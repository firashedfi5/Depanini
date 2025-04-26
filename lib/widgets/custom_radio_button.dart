import 'package:flutter/material.dart';

class CustomRadioButton extends StatelessWidget {
  final String label;
  final String image;
  final int index;
  final int selectedIndex;
  final VoidCallback onPressed;
  final bool borderSide;

  const CustomRadioButton({
    super.key,
    required this.label,
    required this.image,
    required this.index,
    required this.selectedIndex,
    required this.onPressed,
    required this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        side:
            borderSide == true
                ? BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1,
                )
                : BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor:
            selectedIndex == index
                ? Theme.of(context).colorScheme.secondaryContainer
                : Colors.transparent,
      ),
      onPressed: onPressed,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            foregroundImage: image.isNotEmpty ? AssetImage(image) : null,
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
