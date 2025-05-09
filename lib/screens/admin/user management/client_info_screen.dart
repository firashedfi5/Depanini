import 'package:depanini/models/client_account_model.dart';
import 'package:flutter/material.dart';

class ClientInfoScreen extends StatefulWidget {
  final ClientModel clientData;

  const ClientInfoScreen({super.key, required this.clientData});

  @override
  State<ClientInfoScreen> createState() => _ClientInfoScreenState();
}

class _ClientInfoScreenState extends State<ClientInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Client Info')),
      body: Column(
        children: [
          Image.network(widget.clientData.profilPicture!),
          Text(widget.clientData.username!, style: TextStyle(fontSize: 24)),
          Text(widget.clientData.role!, style: TextStyle(fontSize: 24)),
          Text(widget.clientData.phoneNumber!, style: TextStyle(fontSize: 24)),
          Text(widget.clientData.email!, style: TextStyle(fontSize: 24)),
          Text(widget.clientData.localisation!, style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}
