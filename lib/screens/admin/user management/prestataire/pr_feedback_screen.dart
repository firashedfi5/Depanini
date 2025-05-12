import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/feedback_model.dart';
import 'package:depanini/widgets/feedback.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;

class PrFeedbackScreen extends StatefulWidget {
  final String uid;

  const PrFeedbackScreen({super.key, required this.uid});

  @override
  State<PrFeedbackScreen> createState() => _PrFeedbackScreenState();
}

class _PrFeedbackScreenState extends State<PrFeedbackScreen> {
  Future<List<FeedbackModel>> _feedbackList = Future.value([]);

  @override
  void initState() {
    super.initState();
    _feedbackList = fetchFeedbacks();
  }

  Future<List<FeedbackModel>> fetchFeedbacks() async {
    final feedbackRef =
        await _firestore
            .collection('prestataires')
            .doc(widget.uid)
            .collection('feedbacks')
            .orderBy('date', descending: true)
            .get();

    final snapshot =
        feedbackRef.docs.map((doc) => FeedbackModel.fromSnapshot(doc)).toList();

    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedbacks')),
      body: FutureBuilder<List<FeedbackModel>>(
        future: _feedbackList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Aucun avis ajouté pour le moment'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder:
                (context, index) => FeedbackItem(
                  isAdmin: true,
                  feedback: snapshot.data![index],
                  uid: widget.uid,
                ),
          );
        },
      ),
    );
  }
}
