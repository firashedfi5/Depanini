import 'dart:developer' as dev;

import 'package:depanini/widgets/time_picker.dart';
import 'package:depanini/widgets/date_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleAppointmentScreen extends StatefulWidget {
  const ScheduleAppointmentScreen({super.key});

  @override
  State<ScheduleAppointmentScreen> createState() =>
      _ScheduleAppointmentScreenState();
}

class _ScheduleAppointmentScreenState extends State<ScheduleAppointmentScreen> {
  void _submit() {
    if (_selectedDate != null && _selectedTime != null) {
      dev.log(formatter.format(_selectedDate!));
      dev.log(_selectedTime!);
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

  int selected = -1;
  String? _selectedTime;

  DateTime? _selectedDate;
  final formatter = DateFormat.yMd('fr_FR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prendre un RDV')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choisir le date et temps',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              DatePickerWidget(
                onDateSelected: (selectedDate) {
                  _selectedDate = selectedDate;
                },
              ),
              SizedBox(height: 20),
              TimePicker(
                onTimeSelected: (selectedTime) {
                  _selectedTime = selectedTime;
                },
              ),
              ElevatedButton(onPressed: _submit, child: Text('Confirmer')),
            ],
          ),
        ),
      ),
    );
  }
}
