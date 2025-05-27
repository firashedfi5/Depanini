class ProposalModel {
  const ProposalModel({
    required this.prestataireUid,
    required this.prestataireEmail,
    required this.prestatairePhoto,
    required this.username,
    required this.date,
    required this.averageRating,
  });

  final String prestataireUid;
  final String prestataireEmail;
  final String prestatairePhoto;
  final String username;
  final DateTime date;
  final double averageRating;
}
