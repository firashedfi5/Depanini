// TODO: ki tetbadel el localisation lezem tetsajel l'adresse jdida fel les RDV lkol

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/place.dart';
import 'package:depanini/widgets/location_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class ChangeLocation extends ConsumerStatefulWidget {
  const ChangeLocation({super.key});

  @override
  ConsumerState<ChangeLocation> createState() => _ChangeLocationState();
}

class _ChangeLocationState extends ConsumerState<ChangeLocation> {
  PlaceLocation? _selectedLocation;

  void _submit() async {
    if (_selectedLocation == null) {
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
      return;
    }

    final user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid;

    // Try finding the user in the 'clients' collection
    final clientDoc = await _firestore.collection('clients').doc(uid).get();

    String? collectionToUpdate;

    if (clientDoc.exists) {
      collectionToUpdate = 'clients';
    } else {
      // If not found in clients, try in prestataires
      final prestataireDoc =
          await _firestore.collection('prestataires').doc(uid).get();
      if (prestataireDoc.exists) {
        collectionToUpdate = 'prestataires';
      }
    }

    if (collectionToUpdate != null) {
      await _firestore.collection(collectionToUpdate).doc(uid).update({
        'Localisation': _selectedLocation!.address,
        'Latitude&Longitude': GeoPoint(
          _selectedLocation!.latitude,
          _selectedLocation!.longitude,
        ),
      });

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change votre adresse')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 150),
          LocationInput(
            onSelectLocation: (location) {
              _selectedLocation = location;
            },
          ),
          const SizedBox(height: 50),
          ElevatedButton(onPressed: _submit, child: const Text('Enregistrer')),
        ],
      ),
    );
  }
}
