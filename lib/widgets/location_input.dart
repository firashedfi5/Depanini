import 'dart:convert';
// import 'dart:developer' as dev;
import 'package:depanini/models/place.dart';
import 'package:depanini/screens/common/map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;

  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=normal&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyBj1ZcnXcI0Wrt1QpNWLj70OMJP_ZVEpvs';
  }

  Future<void> _savePlace(double latitude, double longitude) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyBj1ZcnXcI0Wrt1QpNWLj70OMJP_ZVEpvs',
    );
    final response = await http.get(url);
    final resData = json.decode(response.body);
    final address = resData['results'][0]['formatted_address'];

    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      _isGettingLocation = false;
    });

    widget.onSelectLocation(_pickedLocation!);
  }

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();

    final lat = locationData.latitude;
    final lng = locationData.longitude;

    if (lat == null || lng == null) {
      return;
    }

    _savePlace(lat, lng);

    // dev.log('Latitude: ${lat.toString()}');
    // dev.log('Longitude: ${lng.toString()}');
    // dev.log('Address: ${address.toString()}');
  }

  void _selectOnMap() async {
    final picedLocation = await Navigator.of(
      context,
    ).push<LatLng>(MaterialPageRoute(builder: (context) => const MapScreen()));

    if (picedLocation == null) {
      return;
    }

    _savePlace(picedLocation.latitude, picedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget previwContenet = Text(
      'Aucun emplacement choisi',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge,
    );

    if (_isGettingLocation) {
      previwContenet = const CircularProgressIndicator();
    }

    if (_pickedLocation != null) {
      previwContenet = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Column(
      children: [
        Text(_pickedLocation?.address ?? ''),
        const SizedBox(height: 15),
        Container(
          height: 250,
          width: MediaQuery.of(context).size.width * 0.9,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withAlpha(150),
            ),
          ),
          child: previwContenet,
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Ma position actuelle'),
            ),
            TextButton.icon(
              onPressed: _selectOnMap,
              icon: const Icon(Icons.map),
              label: const Text('Choisir sur la carte'),
            ),
          ],
        ),
      ],
    );
  }
}
