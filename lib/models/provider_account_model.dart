import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderAccountModel {
  const ProviderAccountModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.description,
    required this.diplome,
    required this.domaine,
    required this.experience,
    required this.phoneNumber,
    required this.profilPicture,
    this.workPicture_1,
    this.workPicture_2,
    this.workPicture_3,
    this.workPicture_4,
  });

  final String uid;
  final String email;
  final String username;
  final String description;
  final String diplome;
  final String domaine;
  final String experience;
  final String phoneNumber;
  final String profilPicture;
  final String? workPicture_1;
  final String? workPicture_2;
  final String? workPicture_3;
  final String? workPicture_4;

  factory ProviderAccountModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
    return ProviderAccountModel(
      uid: data['Uid'],
      email: data['Email'],
      username: data['Nom d\'utilisateur'],
      description: data['Description'],
      diplome: data['Diplôme'],
      domaine: data['Domaine'],
      experience: data['Experience'],
      phoneNumber: data['Numéro de téléphone'],
      profilPicture: data['Photo de profile'],
      workPicture_1: data['Photo de travail n°1'],
      workPicture_2: data['Photo de travail n°2'],
      workPicture_3: data['Photo de travail n°3'],
      workPicture_4: data['Photo de travail n°4'],
    );
  }
}
