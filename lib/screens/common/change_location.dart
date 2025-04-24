import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/place.dart';
// import 'package:depanini/screens/auth/choosing_screen.dart';
import 'package:depanini/widgets/location_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangeLocation extends ConsumerStatefulWidget {
  const ChangeLocation({super.key});

  @override
  ConsumerState<ChangeLocation> createState() => _ChangeLocationState();
}

class _ChangeLocationState extends ConsumerState<ChangeLocation> {
  PlaceLocation? _selectedLocation;

  void _submit() async {
    if (_selectedLocation != null) {
      final userInfo = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(userInfo!.uid)
          .update({
            'Localisation': _selectedLocation!.address,
            'Latitude&Longitude': GeoPoint(
              _selectedLocation!.latitude,
              _selectedLocation!.longitude,
            ),
          });
      if (mounted) {
        Navigator.of(context).pop();
      }
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
          backgroundColor: Color(0xffb3261e),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Change votre adresse')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 150),
          LocationInput(
            onSelectLocation: (location) {
              _selectedLocation = location;
            },
          ),
          SizedBox(height: 50),
          ElevatedButton(onPressed: _submit, child: Text('Enregistrer')),
        ],
      ),
    );
  }
}
