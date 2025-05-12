import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String username;
  final String clientEmail;
  final String report;
  final DateTime date;

  ReportModel({
    required this.username,
    required this.clientEmail,
    required this.report,
    required this.date,
  });

  factory ReportModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return ReportModel(
      username: document['username'],
      clientEmail: document['client_email'],
      report: document['report'] ?? '',
      date: (document['date'] as Timestamp).toDate(),
    );
  }
}
