import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/report_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _firestore = FirebaseFirestore.instance;

class ClReportsScreen extends StatefulWidget {
  final String uid;
  final String username;

  const ClReportsScreen({super.key, required this.uid, required this.username});

  @override
  State<ClReportsScreen> createState() => _ClReportsScreenState();
}

class _ClReportsScreenState extends State<ClReportsScreen> {
  Future<List<ReportModel>> _reportList = Future.value([]);

  @override
  void initState() {
    super.initState();
    _reportList = fetchFeedbacks();
  }

  Future<List<ReportModel>> fetchFeedbacks() async {
    final feedbackRef =
        await _firestore
            .collection('clients')
            .doc(widget.uid)
            .collection('reports')
            .orderBy('date', descending: true)
            .get();

    final snapshot =
        feedbackRef.docs.map((doc) => ReportModel.fromSnapshot(doc)).toList();

    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reports de ${widget.username}')),
      body: FutureBuilder<List<ReportModel>>(
        future: _reportList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Aucun signalement ajouté pour le moment',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 2,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withAlpha(120)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            snapshot.data![index].username,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          Text(
                            DateFormat(
                              'dd MMM yyyy',
                            ).format(snapshot.data![index].date),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        snapshot.data![index].report,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
