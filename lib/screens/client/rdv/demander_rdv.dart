import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/widgets/date_picker.dart';
import 'package:depanini/widgets/time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class DemanderRdv extends StatefulWidget {
  final String prestataireUid;
  final String prestataireUsername;
  final String prestataireProfilePicture;
  final String prestataireLocation;
  final List<double> prestataireLatLong;
  final String service;

  const DemanderRdv({
    super.key,
    required this.prestataireUid,
    required this.prestataireUsername,
    required this.prestataireProfilePicture,
    required this.prestataireLocation,
    required this.prestataireLatLong,
    required this.service,
  }); // *Constructeur

  @override
  State<DemanderRdv> createState() => _DemanderRdvState();
}

class _DemanderRdvState extends State<DemanderRdv> {
  List<String> _bookedTimes =
      []; // *Liste pour enregistrer les temps indisponibles
  int selected = -1;
  String? _selectedTime;
  DateTime? _selectedDate;
  final formatter = DateFormat.yMd('fr_FR');

  // *Fetchina les temps indisponibles
  Future<List<String>> getBookedTimes() async {
    final startOfDay = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
    );
    final startOfNextDay = startOfDay.add(const Duration(days: 1));

    final querySnapshot =
        await _firestore
            .collection('rdvs')
            .where('prestataire_uid', isEqualTo: widget.prestataireUid)
            .where('status', isEqualTo: 'confirmé')
            .where('date', isGreaterThanOrEqualTo: startOfDay)
            .where('date', isLessThan: startOfNextDay)
            .get();

    return querySnapshot.docs
        .map((doc) => doc.data()['heure'] as String)
        .toSet()
        .toList();
  }

  // *Tsajel RDV fel Firestore
  void _submit() async {
    if (_selectedDate != null && _selectedTime != null) {
      dev.log(formatter.format(_selectedDate!));
      dev.log(_selectedTime!);

      if (mounted) {
        Navigator.of(context).pop();
      }

      // *Tfetchi les données mte3 l client mel Firestore
      final user = _auth.currentUser!;
      final userDoc =
          await _firestore.collection("clients").doc(user.uid).get();
      final userData = userDoc.data();
      final clientUsername = userData!['Nom d\'utilisateur'];
      final clientProfilePicture = userData['Photo de profile'];
      final clientLocation = userData['Localisation'];
      final clientLatLong = userData['Latitude&Longitude'];

      // *Tsajel les données mte3 RDV fel Firestore
      _firestore.collection("rdvs").add({
        'client_uid': _auth.currentUser!.uid,
        'prestataire_uid': widget.prestataireUid,
        'client_username': clientUsername,
        'client_profile_picture': clientProfilePicture,
        'prestataire_username': widget.prestataireUsername,
        'prestataire_profile_picture': widget.prestataireProfilePicture,
        'service': widget.service,
        'date': Timestamp.fromDate(
          DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
          ),
        ),
        'heure': _selectedTime!,
        'createdAt': Timestamp.now(),
        'status': 'en_attente',
        'client_location': clientLocation,
        'client_Lat&Long': GeoPoint(
          clientLatLong.latitude,
          clientLatLong.longitude,
        ),
        'prestataire_location': widget.prestataireLocation,
        'prestataire_Lat&Long': GeoPoint(
          widget.prestataireLatLong[0],
          widget.prestataireLatLong[1],
        ),
      });

      // *Bech tetsajel notification fel Firestore
      _firestore.collection("notifications").add({
        'expéditeur_uid': _auth.currentUser!.uid,
        'récepteur_uid': widget.prestataireUid,
        'type': 'rdv',
        'titre': 'Nouvelle demande de rendez-vous',
        'contenu':
            'Vous avez une nouvelle demande de rendez-vous de la part de $clientUsername.',
        'date': Timestamp.now(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              textAlign: TextAlign.center,
              'Demande de rendez-vous envoyée avec succès.',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veuillez sélectionner une date et une heure.',
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
      appBar: AppBar(title: const Text('Demander un rendez-vous')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choisir la date',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DatePickerWidget(
                    onDateSelected: (selectedDate) async {
                      _selectedDate = selectedDate;
                      if (_selectedDate != null) {
                        final List<String> times = await getBookedTimes();
                        dev.log('heures réservées: $times');
                        setState(() {
                          _bookedTimes = times;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choisir l\'heure',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TimePicker(
                    bookedTimes: _bookedTimes,
                    selectedDate: _selectedDate,
                    onTimeSelected: (selectedTime) {
                      _selectedTime = selectedTime;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Confirmer le rendez-vous'),
            ),
          ],
        ),
      ),
    );
  }
}
