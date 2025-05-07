import 'package:cloud_firestore/cloud_firestore.dart';

class AstuceModel {
  const AstuceModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.domaine,
    this.foregroundImage,
    required this.createdAt,
    // this.image2,
    // this.image3,
    // this.image4,
  });

  final String id;
  final String titre;
  final String domaine;
  final String description;
  final String? foregroundImage;
  final Timestamp createdAt;
  // final String? image2;
  // final String? image3;
  // final String? image4;
}
