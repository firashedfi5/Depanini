import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/proposal_model.dart';
import 'package:depanini/screens/client/home/info_du_prestataire_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

final _firestore = FirebaseFirestore.instance;

class PropostionsScreen extends StatefulWidget {
  final String postId;

  const PropostionsScreen({super.key, required this.postId});

  @override
  State<PropostionsScreen> createState() => _PropostionsScreenState();
}

class _PropostionsScreenState extends State<PropostionsScreen> {
  Future<List<ProposalModel>> _proposalsList = Future.value([]);

  Future<List<ProposalModel>> _loadProposals() async {
    try {
      final snapshot =
          await _firestore
              .collection('annonces')
              .doc(widget.postId)
              .collection('propositions')
              .orderBy("prestataire_averageRating", descending: true)
              .get();

      final List<ProposalModel> loadedAstuces =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return ProposalModel(
              prestataireUid: data['prestataire_uid'],
              prestataireEmail: data['prestataire_email'],
              prestatairePhoto: data['prestataire_photo'],
              username: data['username'],
              date: (data['date'] as Timestamp).toDate(),
              averageRating:
                  (data['prestataire_averageRating'] ?? 0.0).toDouble(),
            );
          }).toList();

      return loadedAstuces;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des propostions: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _proposalsList = _loadProposals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Propositions')),
      body: FutureBuilder(
        future: _proposalsList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Aucune proposition n’a encore été soumise.'),
            );
          }
          final proposals = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: proposals.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 4,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withAlpha(120)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        foregroundImage: CachedNetworkImageProvider(
                          proposals[index].prestatairePhoto,
                          cacheKey: proposals[index].prestatairePhoto,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              proposals[index].username,
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: proposals[index].averageRating,
                                  itemBuilder:
                                      (context, index) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                  itemCount: 5,
                                  itemSize: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  proposals[index].averageRating
                                      .toStringAsFixed(2),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 35),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => InfoDuPrestataireScreen(
                                    uid: proposals[index].prestataireUid,
                                    email: proposals[index].prestataireEmail,
                                  ),
                            ),
                          );
                        },
                        label: const Text('Voir profil'),
                        icon: const Icon(Icons.person),
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
