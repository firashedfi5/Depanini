import 'dart:developer' as dev;

import 'package:depanini/widgets/custom_time_radio_button.dart';
import 'package:depanini/widgets/date_time_picker.dart';
import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class ScheduleAppointmentScreen extends StatefulWidget {
  const ScheduleAppointmentScreen({super.key});

  @override
  State<ScheduleAppointmentScreen> createState() =>
      _ScheduleAppointmentScreenState();
}

class _ScheduleAppointmentScreenState extends State<ScheduleAppointmentScreen> {
  void _submit() {
    if (_selectedDate != null && selectedTime != null) {
      dev.log('$selectedTime\n${formatter.format(_selectedDate!)}');
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

  List<String> time = ["09:00", "10:00", "11:00", "15:00", "16:00", "17:00"];
  int selected = -1;
  String? selectedTime;

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
                onDateSelected: (DateTime selected) {
                  _selectedDate = selected;
                },
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 60,
                child: ListView.separated(
                  separatorBuilder: (_, _) => SizedBox(width: 10),
                  scrollDirection: Axis.horizontal,
                  itemCount: time.length,
                  itemBuilder:
                      (context, index) => CustomTimeRadioButton(
                        borderSide: true,
                        index: index,
                        label: time[index],
                        selectedIndex: selected,
                        onPressed: () {
                          setState(() {
                            if (selected == index) {
                              selected = -1;
                              selectedTime = null;
                            } else {
                              selected = index;
                              selectedTime = time[index];
                            }
                            dev.log(selected.toString());
                            dev.log(selectedTime ?? 'null');
                          });
                        },
                      ),
                ),
              ),
              ElevatedButton(onPressed: _submit, child: Text('Confirmer')),
            ],
          ),
        ),
      ),
    );
  }
}
