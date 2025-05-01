import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  const PostModel({
    required this.postId,
    required this.uid,
    required this.email,
    required this.username,
    required this.phoneNumber,
    required this.profilPicture,
    required this.description,
    required this.service,
    required this.date,
    required this.createdAt,
    this.image1,
    this.image2,
    this.image3,
    this.image4,
  });

  final String postId;
  final String uid;
  final String email;
  final String username;
  final String phoneNumber;
  final String profilPicture;
  final String service;
  final String description;
  final String date;
  final Timestamp createdAt;
  final String? image1;
  final String? image2;
  final String? image3;
  final String? image4;
}
