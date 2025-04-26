import 'package:flutter/material.dart';

class ScheduleAppointmentScreen extends StatefulWidget {
  const ScheduleAppointmentScreen({super.key});

  @override
  State<ScheduleAppointmentScreen> createState() =>
      _ScheduleAppointmentScreenState();
}

class _ScheduleAppointmentScreenState extends State<ScheduleAppointmentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prendre un RDV')),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Choisir le date et temps',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(onPressed: () {}, child: Text('Confirmer')),
          ],
        ),
      ),
    );
  }
}
