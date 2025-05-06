import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/place.dart';

class ClientModel {
  const ClientModel({
    this.username,
    this.phoneNumber,
    this.email,
    this.password,
    this.profilImage,
    this.profilPicture,
    this.role,
    this.location,
    this.localisation,
    this.latitude,
    this.longitude,
  });
  final String? username;
  final String? phoneNumber;
  final String? email;
  final String? password;
  final File? profilImage;
  final String? profilPicture;
  final String? role;
  final PlaceLocation? location;
  final String? localisation;
  final double? latitude;
  final double? longitude;
  // Method to copy state with new values
  ClientModel copyWith({
    String? username,
    String? phoneNumber,
    String? email,
    String? password,
    File? profilImage,
    String? role,
    PlaceLocation? location,
  }) {
    return ClientModel(
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      password: password ?? this.password,
      profilImage: profilImage ?? this.profilImage,
      role: role ?? this.role,
      location: location ?? this.location,
    );
  }

  factory ClientModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (data == null) {
      throw Exception('Document data is null');
    }
    final geoPoint = data['Latitude&Longitude'] as GeoPoint;

    return ClientModel(
      email: data['Email'],
      username: data['Nom d\'utilisateur'],
      phoneNumber: data['Numéro de téléphone'],
      role: data['Rôle'],
      profilPicture: data['Photo de profile'] ?? "",
      localisation: data['Localisation'] ?? '',
      latitude: geoPoint.latitude,
      longitude: geoPoint.longitude,
    );
  }
}
