class RdvModel {
  const RdvModel({
    required this.id,
    required this.clientUid,
    required this.prestataireUid,
    required this.clientUsername,
    required this.prestataireUsername,
    required this.service,
    required this.date,
    required this.heure,
  });

  final int id;
  final String clientUid;
  final String prestataireUid;
  final String clientUsername;
  final String prestataireUsername;
  final String service;
  final String date;
  final String heure;
}
