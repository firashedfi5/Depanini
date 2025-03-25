import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderAccountModel {
  const ProviderAccountModel({
    required this.username,
    required this.description,
    required this.diplome,
    required this.domaine,
    required this.phoneNumber,
    required this.profilPicture,
    // this.image2,
    // this.image3,
    // this.image4,
  });

  final String username;
  final String description;
  final String diplome;
  final String domaine;
  final String phoneNumber;
  final String profilPicture;
  // final String? image2;
  // final String? image3;
  // final String? image4;

  factory ProviderAccountModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
    return ProviderAccountModel(
      username: data['Nom d\'utilisateur'],
      description: data['Description'],
      diplome: data['Diplôme'],
      domaine: data['Domaine'],
      phoneNumber: data['Numéro de téléphone'],
      profilPicture: data['Photo de profile'],
    );
  }
}
