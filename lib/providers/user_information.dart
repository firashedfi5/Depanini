import 'dart:io';
import 'package:depanini/models/place.dart';
import 'package:depanini/models/signup_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserInformationNotifier extends StateNotifier<SignupModel> {
  UserInformationNotifier() : super(const SignupModel());

  void updateUsername(String userName) {
    state = state.copyWith(userName: userName);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email); // Replace state immutably
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void updatePhoneNumber(String phoneNumber) {
    state = state.copyWith(phoneNumber: phoneNumber);
  }

  void updateProfilImage(File profilImage) {
    state = state.copyWith(profilImage: profilImage);
  }

  void updateRole(String role) {
    state = state.copyWith(role: role);
  }

  void updateLocation(PlaceLocation location) {
    state = state.copyWith(location: location);
  }
}

final userInformationProvdier =
    StateNotifierProvider<UserInformationNotifier, SignupModel>(
      (ref) => UserInformationNotifier(),
    );
