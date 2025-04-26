import 'package:flutter/material.dart';

class CustomTimeRadioButton extends StatelessWidget {
  final String label;
  final int index;
  final int selectedIndex;
  final VoidCallback onPressed;
  final bool borderSide;

  const CustomTimeRadioButton({
    super.key,
    required this.label,
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
                ? BorderSide(color: Theme.of(context).colorScheme.primary)
                : BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor:
            selectedIndex == index
                ? Theme.of(context).colorScheme.secondaryContainer
                : Colors.transparent,
      ),
      onPressed: onPressed,
      child: Center(
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
