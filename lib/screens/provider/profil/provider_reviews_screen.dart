import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/feedback_model.dart';
import 'package:depanini/widgets/feedback.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class ProviderReviewsScreen extends StatefulWidget {
  const ProviderReviewsScreen({super.key});

  @override
  State<ProviderReviewsScreen> createState() => _ProviderReviewsScreenState();
}

class _ProviderReviewsScreenState extends State<ProviderReviewsScreen> {
  Future<List<FeedbackModel>> _feedbackList = Future.value([]);
  final String uid = _auth.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _feedbackList = fetchFeedbacks();
  }

  Future<List<FeedbackModel>> fetchFeedbacks() async {
    final feedbackRef =
        await _firestore
            .collection('prestataires')
            .doc(uid)
            .collection('feedbacks')
            .orderBy('date', descending: true)
            .get();

    return feedbackRef.docs
        .map((doc) => FeedbackModel.fromSnapshot(doc))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes notes et avis')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withAlpha(120)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder(
                    future: Future.wait([
                      _firestore.collection('prestataires').doc(uid).get(),
                      _firestore
                          .collection('prestataires')
                          .doc(uid)
                          .collection('ratings')
                          .get(),
                    ]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Erreur de chargement',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        );
                      }

                      final prestataireSnapshot =
                          snapshot.data![0] as DocumentSnapshot;
                      final ratingsSnapshot =
                          snapshot.data![1] as QuerySnapshot;

                      final prestataireData =
                          prestataireSnapshot.data() as Map<String, dynamic>? ??
                          {};
                      final averageRating =
                          (prestataireData['averageRating']).toDouble();
                      final totalReviews = ratingsSnapshot.docs.length;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ÉVALUATION MOYENNE',
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                averageRating.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RatingBarIndicator(
                                    rating: averageRating,
                                    itemBuilder:
                                        (context, index) => const Icon(
                                          Icons.star_rounded,
                                          color: Colors.amberAccent,
                                        ),
                                    itemCount: 5,
                                    itemSize: 28,
                                    unratedColor:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$totalReviews avis',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 4,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Avis récents',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              FutureBuilder<List<FeedbackModel>>(
                future: _feedbackList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
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
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder:
                        (context, index) => FeedbackItem(
                          isAdmin: true,
                          feedback: snapshot.data![index],
                          uid: uid,
                        ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
