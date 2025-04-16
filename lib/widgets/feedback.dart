import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/feedback_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class FeedbackItem extends StatefulWidget {
  final FeedbackModel feedback;
  final String uid;

  const FeedbackItem({super.key, required this.feedback, required this.uid});

  @override
  State<FeedbackItem> createState() => _FeedbackItemState();
}

class _FeedbackItemState extends State<FeedbackItem> {
  Future<double?> _loadPreviousRating() async {
    final ratingDoc =
        await _firestore
            .collection('prestataires')
            .doc(widget.uid)
            .collection('ratings')
            .doc(widget.feedback.clientEmail)
            .get();

    if (ratingDoc.exists) {
      final ratingData = ratingDoc.data();
      final rating = ratingData?['rating'];

      if (rating is num) {
        return rating.toDouble();
      }
    }

    return null; // No valid rating found
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.feedback.username,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('dd MMM yyyy').format(widget.feedback.date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.feedback.comment,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                FutureBuilder<double?>(
                  future: _loadPreviousRating(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(strokeWidth: 2);
                    } else if (snapshot.hasError) {
                      return const Text("Erreur de chargement");
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Text(
                        "Pas encore de note.",
                        style: Theme.of(context).textTheme.labelSmall,
                      );
                    }

                    return RatingBarIndicator(
                      rating: snapshot.data!,
                      itemBuilder:
                          (context, index) =>
                              const Icon(Icons.star, color: Colors.amber),
                      itemCount: 5,
                      itemSize: 18,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
