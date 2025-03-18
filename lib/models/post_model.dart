import 'dart:io';

class PostModel {
  const PostModel({
    required this.description,
    required this.service,
    required this.date,
    this.image1,
    this.image2,
    this.image3,
    this.image4,
  });

  final String service;
  final String description;
  final String date;
  final File? image1;
  final File? image2;
  final File? image3;
  final File? image4;
}
