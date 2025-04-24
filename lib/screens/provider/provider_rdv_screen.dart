import 'package:flutter/material.dart';

class ProviderRdvScreen extends StatefulWidget {
  const ProviderRdvScreen({super.key});

  @override
  State<ProviderRdvScreen> createState() => _ProviderRdvScreenState();
}

class _ProviderRdvScreenState extends State<ProviderRdvScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mes rendez-vous')),
      body: Center(
        child: Text(
          'Pas encore de rendez-vous',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
