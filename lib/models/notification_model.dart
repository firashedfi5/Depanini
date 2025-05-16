class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.type,
    required this.titre,
    required this.contenu,
    required this.date,
  });

  final String id;
  final String type;
  final String titre;
  final String contenu;
  final DateTime date;
}
