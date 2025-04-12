import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String username;
  final String clientEmail;
  final String comment;
  final DateTime date;

  FeedbackModel({
    required this.username,
    required this.clientEmail,
    required this.comment,
    required this.date,
  });

  factory FeedbackModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return FeedbackModel(
      username: document['username'],
      clientEmail: document['client_email'],
      comment: document['comment'] ?? '',
      date: (document['date'] as Timestamp).toDate(),
    );
  }
}
