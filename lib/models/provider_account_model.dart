import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderAccountModel {
  const ProviderAccountModel({
    required this.email,
    required this.username,
    required this.description,
    required this.diplome,
    required this.domaine,
    required this.experience,
    required this.phoneNumber,
    required this.profilPicture,
  });

  final String email;
  final String username;
  final String description;
  final String diplome;
  final String domaine;
  final String experience;
  final String phoneNumber;
  final String profilPicture;

  factory ProviderAccountModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
    return ProviderAccountModel(
      email: data['Email'],
      username: data['Nom d\'utilisateur'],
      description: data['Description'],
      diplome: data['Diplôme'],
      domaine: data['Domaine'],
      experience: data['Experience'],
      phoneNumber: data['Numéro de téléphone'],
      profilPicture: data['Photo de profile'],
    );
  }
}
