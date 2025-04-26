import 'dart:developer' as dev;

import 'package:depanini/widgets/custom_time_radio_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      dev.log('Veuillez sélectionner une date et une heure.');
    }
  }

  List<String> time = ["09:00", "10:00", "11:00", "15:00", "16:00", "17:00"];
  int selected = -1;
  String? selectedTime;

  DateTime? _selectedDate;
  final formatter = DateFormat.yMd();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prendre un RDV')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Choisir le date et temps',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(
              height: 35,
              width: 350,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final lastDate = DateTime(now.year, now.month, now.day + 7);
                  final pickedDate = await showDatePicker(
                    context: context,
                    firstDate: now,
                    lastDate: lastDate,
                  );
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                },
                label: Text('Sélectionner un date'),
                icon: FaIcon(FontAwesomeIcons.calendarCheck),
              ),
            ),
            Text(
              _selectedDate == null ? '' : formatter.format(_selectedDate!),
              style: Theme.of(context).textTheme.labelLarge,
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
                      // image: "",
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
    );
  }
}
