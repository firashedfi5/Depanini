import 'package:depanini/models/place.dart';
import 'package:depanini/providers/user_information.dart';
import 'package:depanini/screens/auth/choosing_screen.dart';
import 'package:depanini/widgets/location_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocalizationScreen extends ConsumerStatefulWidget {
  const LocalizationScreen({super.key});

  @override
  ConsumerState<LocalizationScreen> createState() => _LocalizationScreenState();
}

class _LocalizationScreenState extends ConsumerState<LocalizationScreen> {
  PlaceLocation? _selectedLocation;

  void _submit() {
    // final userInfo = ref.watch(userInformationProvdier);
    if (_selectedLocation != null) {
      ref
          .read(userInformationProvdier.notifier)
          .updateLocation(_selectedLocation!);
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const ChoosingScreen()));
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veuillez choisir un emplacement.',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: const Color(0xffb3261e),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Localisation')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 170),
          LocationInput(
            onSelectLocation: (location) {
              _selectedLocation = location;
            },
          ),
          const SizedBox(height: 80),
          ElevatedButton(onPressed: _submit, child: const Text('Suivant')),
        ],
      ),
    );
  }
}
