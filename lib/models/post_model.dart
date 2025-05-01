class PostModel {
  const PostModel({
    required this.id,
    required this.uid,
    required this.email,
    required this.username,
    required this.phoneNumber,
    required this.profilPicture,
    required this.description,
    required this.service,
    required this.date,
    this.image1,
    this.image2,
    this.image3,
    this.image4,
  });

  final String id;
  final String uid;
  final String email;
  final String username;
  final String phoneNumber;
  final String profilPicture;
  final String service;
  final String description;
  final String date;
  final String? image1;
  final String? image2;
  final String? image3;
  final String? image4;
}
