import 'package:depanini/models/provider_account_model.dart';
import 'package:flutter/material.dart';

class PrestataireInfoScreen extends StatefulWidget {
  final ProviderAccountModel providerData;

  const PrestataireInfoScreen({super.key, required this.providerData});

  @override
  State<PrestataireInfoScreen> createState() => _PrestataireInfoScreenState();
}

class _PrestataireInfoScreenState extends State<PrestataireInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prestataire Info')),
      body: Column(
        children: [
          Image.network(widget.providerData.profilPicture),
          Text(widget.providerData.username, style: TextStyle(fontSize: 24)),
          Text(widget.providerData.role, style: TextStyle(fontSize: 24)),
          Text(widget.providerData.phoneNumber, style: TextStyle(fontSize: 24)),
          Text(widget.providerData.email, style: TextStyle(fontSize: 24)),
          Text(widget.providerData.localisation, style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}
