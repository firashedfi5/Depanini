class ProviderAccountModel {
  const ProviderAccountModel({
    required this.username,
    required this.description,
    required this.diplome,
    required this.domaine,
    required this.phoneNumber,
    this.profilPicture,
    // this.image2,
    // this.image3,
    // this.image4,
  });

  final String username;
  final String description;
  final String diplome;
  final String domaine;
  final String phoneNumber;
  final String? profilPicture;
  // final String? image2;
  // final String? image3;
  // final String? image4;
}
