import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/widgets/time_picker.dart';
import 'package:depanini/widgets/date_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class ScheduleAppointmentScreen extends StatefulWidget {
  final String prestataireUid;
  final String prestataireUsername;
  final String prestataireProfilePicture;
  final String prestataireLocation;
  final List<double> prestataireLatLong;
  final String service;

  const ScheduleAppointmentScreen({
    super.key,
    required this.prestataireUid,
    required this.prestataireUsername,
    required this.prestataireProfilePicture,
    required this.prestataireLocation,
    required this.prestataireLatLong,
    required this.service,
  });

  @override
  State<ScheduleAppointmentScreen> createState() =>
      _ScheduleAppointmentScreenState();
}

class _ScheduleAppointmentScreenState extends State<ScheduleAppointmentScreen> {
  int selected = -1;
  String? _selectedTime;

  DateTime? _selectedDate;
  final formatter = DateFormat.yMd('fr_FR');

  void _submit() async {
    if (_selectedDate != null && _selectedTime != null) {
      dev.log(formatter.format(_selectedDate!));
      dev.log(_selectedTime!);
      // *********************************
      if (mounted) {
        Navigator.of(context).pop();
      }
      // *********************************
      final user = _auth.currentUser!;
      final userDoc =
          await _firestore.collection("clients").doc(user.uid).get();
      final userData = userDoc.data();
      final clientUsername = userData!['Nom d\'utilisateur'];
      final clientProfilePicture = userData['Photo de profile'];
      final clientLocation = userData['Localisation'];
      final clientLatLong = userData['Latitude&Longitude'];
      // *********************************
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
              'Rdv est enregistré.',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      // *********************************
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
          backgroundColor: Color(0xffb3261e),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détails de réservation')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20),
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
                  SizedBox(height: 12),
                  DatePickerWidget(
                    onDateSelected: (selectedDate) {
                      _selectedDate = selectedDate;
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

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
                  SizedBox(height: 12),
                  TimePicker(
                    onTimeSelected: (selectedTime) {
                      _selectedTime = selectedTime;
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 100),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Confirmer la réservation'),
            ),
          ],
        ),
      ),
    );
  }
}
