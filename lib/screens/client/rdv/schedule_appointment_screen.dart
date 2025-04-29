import 'dart:convert';
import 'dart:developer' as dev;

import 'package:depanini/widgets/time_picker.dart';
import 'package:depanini/widgets/date_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

final _auth = FirebaseAuth.instance;

class ScheduleAppointmentScreen extends StatefulWidget {
  const ScheduleAppointmentScreen({super.key});

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
      final url = Uri.http(
        '10.0.2.2:3300',
        'ajouter-rdv',
      ); // Virtual Device: 10.0.2.2 - Actual Device: 192.168.1.11 (ipconfig -> IPv4)
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'client_uid': _auth.currentUser!.uid,
          'prestataire_uid': '',
          'client_username': '',
          'prestataire_username': '',
          'service': '',
          'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
          'heure': _selectedTime!,
        }),
      ); // Virtual Device: 10.0.2.2 - Actual Device: 192.168.1.11 (ipconfig -> IPv4)
      // *********************************
    } else {
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
