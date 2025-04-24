import 'package:flutter/material.dart';

class ClientRdvScreen extends StatefulWidget {
  const ClientRdvScreen({super.key});

  @override
  State<ClientRdvScreen> createState() => _ClientRdvScreenState();
}

class _ClientRdvScreenState extends State<ClientRdvScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Mes rendez-vous')));
  }
}
