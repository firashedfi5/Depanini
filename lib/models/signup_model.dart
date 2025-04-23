import 'dart:io';

import 'package:depanini/models/place.dart';

class SignupModel {
  const SignupModel({
    this.userName,
    this.phoneNumber,
    this.email,
    this.password,
    this.profilImage,
    this.role,
    this.location,
  });
  final String? userName;
  final String? phoneNumber;
  final String? email;
  final String? password;
  final File? profilImage;
  final String? role;
  final PlaceLocation? location;
  // Method to copy state with new values
  SignupModel copyWith({
    String? userName,
    String? phoneNumber,
    String? email,
    String? password,
    File? profilImage,
    String? role,
    PlaceLocation? location,
  }) {
    return SignupModel(
      userName: userName ?? this.userName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      password: password ?? this.password,
      profilImage: profilImage ?? this.profilImage,
      role: role ?? this.role,
      location: location ?? this.location,
    );
  }
}
