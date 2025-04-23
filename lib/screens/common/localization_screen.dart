import 'package:depanini/models/place.dart';
import 'package:depanini/widgets/location_input.dart';
import 'package:flutter/material.dart';

class LocalizationScreen extends StatefulWidget {
  const LocalizationScreen({super.key});

  @override
  State<LocalizationScreen> createState() => _LocalizationScreenState();
}

class _LocalizationScreenState extends State<LocalizationScreen> {
  PlaceLocation? _selectedLocation;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Localisation')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [SizedBox(height: 170),
          LocationInput(
            onSelectLocation: (location) {
              _selectedLocation = location;
            },
          ),
        ],
      ),
    );
  }
}
