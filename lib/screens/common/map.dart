import 'package:depanini/models/place.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const PlaceLocation(
      latitude: 36.8065,
      longitude: 10.1815,
      address: '',
    ),
    this.isSelecting = true,
  });

  final PlaceLocation location;
  final bool isSelecting;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isSelecting
              ? 'Choisir votre position'
              : 'Ta position actuelle',
        ),
        actions: [
          if (widget.isSelecting)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                Navigator.of(context).pop(_pickedLocation);
              },
            ),
        ],
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        onTap:
            !widget.isSelecting
                ? null
                : (position) {
                  setState(() {
                    _pickedLocation = position;
                  });
                },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.location.latitude, widget.location.longitude),
          zoom: 16,
        ),
        markers:
            (_pickedLocation == null && widget.isSelecting)
                ? {}
                : {
                  Marker(
                    markerId: const MarkerId('m1'),
                    position:
                        _pickedLocation ??
                        LatLng(
                          widget.location.latitude,
                          widget.location.longitude,
                        ),
                    infoWindow: InfoWindow(
                      title: 'Firas Hedfi',
                      snippet: 'Mécanique',
                    ),
                  ),
                },
      ),
    );
  }
}
