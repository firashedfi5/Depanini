class RdvModel {
  const RdvModel({
    required this.id,
    required this.clientUid,
    required this.prestataireUid,
    required this.clientUsername,
    required this.clientProfilePicture,
    required this.prestataireUsername,
    required this.prestataireProfilePicture,
    required this.service,
    required this.date,
    required this.heure,
  });

  final String id;
  final String clientUid;
  final String prestataireUid;
  final String clientUsername;
  final String clientProfilePicture;
  final String prestataireUsername;
  final String prestataireProfilePicture;
  final String service;
  final DateTime date;
  final String heure;
}
