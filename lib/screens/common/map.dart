import 'package:depanini/models/place.dart';
import 'package:depanini/models/provider_account_model.dart';
import 'package:depanini/screens/client/home/provider_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const PlaceLocation(
      latitude: 36.8065,
      longitude: 10.1815,
      address: '',
    ),
    this.prestataireLocations = const [],
    this.prestataireInfo = const [],
    this.isSelecting = true,
    this.isDrectionning = false,
  });

  final PlaceLocation location;
  final List<PlaceLocation> prestataireLocations;
  final List<ProviderAccountModel> prestataireInfo;
  final bool isSelecting;
  final bool isDrectionning;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // ***********Direction*********************
  List<LatLng> polylineCoordinates = [];
  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: 'AIzaSyBj1ZcnXcI0Wrt1QpNWLj70OMJP_ZVEpvs',
      request: PolylineRequest(
        origin: PointLatLng(
          widget.location.latitude,
          widget.location.longitude,
        ),
        destination: PointLatLng(
          widget.prestataireLocations[0].latitude,
          widget.prestataireLocations[0].longitude,
        ),
        mode: TravelMode.driving,
      ),
    );
    if (result.points.isNotEmpty) {
      // ignore: avoid_function_literals_in_foreach_calls
      result.points.forEach(
        (PointLatLng point) =>
            polylineCoordinates.add(LatLng(point.latitude, point.longitude)),
      );
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getPolyPoints();
  }
  // *****************************************

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
                  ),
                  if (widget.prestataireLocations.isNotEmpty)
                    for (int i = 0; i < widget.prestataireLocations.length; i++)
                      Marker(
                        markerId: MarkerId('m${i.toString()}'),
                        position: LatLng(
                          widget.prestataireLocations[i].latitude,
                          widget.prestataireLocations[i].longitude,
                        ),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue,
                        ),
                        infoWindow:
                            widget.prestataireInfo.isNotEmpty
                                ? InfoWindow(
                                  onTap:
                                      () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder:
                                              (context) => ProviderInfoScreen(
                                                email:
                                                    widget
                                                        .prestataireInfo[i]
                                                        .email,
                                                uid:
                                                    widget
                                                        .prestataireInfo[i]
                                                        .uid,
                                              ),
                                        ),
                                      ),
                                  title: widget.prestataireInfo[i].username,
                                  snippet: widget.prestataireInfo[i].domaine,
                                )
                                : InfoWindow.noText,
                      ),
                },
        polylines:
            widget.isDrectionning == true
                ? {
                  Polyline(
                    polylineId: PolylineId("route"),
                    points: polylineCoordinates,
                    color: Colors.cyanAccent,
                    width: 7,
                  ),
                }
                : {},
      ),
    );
  }
}
