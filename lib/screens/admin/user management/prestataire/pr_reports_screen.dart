import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/report_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _firestore = FirebaseFirestore.instance;

class PrReportsScreen extends StatefulWidget {
  final String uid;
  final String username;

  const PrReportsScreen({super.key, required this.uid, required this.username});

  @override
  State<PrReportsScreen> createState() => _PrReportsScreenState();
}

class _PrReportsScreenState extends State<PrReportsScreen> {
  Future<List<ReportModel>> _reportList = Future.value([]);

  @override
  void initState() {
    super.initState();
    _reportList = fetchFeedbacks();
  }

  Future<List<ReportModel>> fetchFeedbacks() async {
    final feedbackRef =
        await _firestore
            .collection('prestataires')
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
      appBar: AppBar(title: Text('Signalements sur ${widget.username}')),
      body: FutureBuilder<List<ReportModel>>(
        future: _reportList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Aucun signalement ajouté pour le moment',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
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
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat(
                              'dd MMM yyyy',
                              'fr',
                            ).format(snapshot.data![index].date),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Text(
                        snapshot.data![index].report,
                        style: Theme.of(context).textTheme.bodyMedium,
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
