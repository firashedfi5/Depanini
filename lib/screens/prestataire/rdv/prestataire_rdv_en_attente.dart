import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/place.dart';
import 'package:depanini/models/rdv_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class PrestataireRdvEnAttente extends StatefulWidget {
  const PrestataireRdvEnAttente({super.key});

  @override
  State<PrestataireRdvEnAttente> createState() =>
      _PrestataireRdvEnAttenteState();
}

class _PrestataireRdvEnAttenteState
    extends State<PrestataireRdvEnAttente> {
  // *******************************
  Stream<List<RdvModel>> getPendingRdvsStream() {
    return _firestore
        .collection('rdvs')
        .where('prestataire_uid', isEqualTo: _auth.currentUser!.uid)
        .where('status', isEqualTo: 'en_attente')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                return RdvModel(
                  id: doc.id,
                  clientUid: data['client_uid'],
                  clientUsername: data['client_username'],
                  clientProfilePicture: data['client_profile_picture'],
                  clientLocation: PlaceLocation(
                    latitude: data['client_Lat&Long'].latitude,
                    longitude: data['client_Lat&Long'].longitude,
                    address: data['client_location'],
                  ),
                  prestataireLocation: PlaceLocation(
                    latitude: data['prestataire_Lat&Long'].latitude,
                    longitude: data['prestataire_Lat&Long'].longitude,
                    address: data['prestataire_location'],
                  ),
                  prestataireUid: data['prestataire_uid'],
                  prestataireUsername: data['prestataire_username'],
                  prestataireProfilePicture:
                      data['prestataire_profile_picture'],
                  service: data['service'],
                  date: (data['date'] as Timestamp).toDate(),
                  heure: data['heure'],
                  status: data['status'],
                );
              }).toList(),
        );
  }
  // *******************************

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: StreamBuilder(
          stream: getPendingRdvsStream(),
          builder:
              (context, snapshot) => Builder(
                builder: (context) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Aucune réservation en attente'),
                    );
                  }

                  final items = snapshot.data!;

                  return CustomScrollView(
                    slivers: [
                      SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context,
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.only(
                          left: 8,
                          right: 8,
                          top: 8,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return Card(
                              elevation: 2,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest
                                          .withAlpha(100)
                                      : Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  top: 8,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          foregroundImage:
                                              CachedNetworkImageProvider(
                                                items[index]
                                                    .clientProfilePicture,
                                                cacheKey:
                                                    items[index]
                                                        .clientProfilePicture,
                                              ),
                                          backgroundColor: Colors.blue.shade50,
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.blue.shade800,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              items[index].clientUsername,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              items[index].service,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade200
                                                .withAlpha(50),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Text(
                                            'En attente',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium!.copyWith(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _InfoChip(
                                          icon: Icons.calendar_today,
                                          text: DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(items[index].date),
                                        ),
                                        const SizedBox(width: 30),
                                        _InfoChip(
                                          icon: Icons.access_time,
                                          text: items[index].heure,
                                        ),
                                      ],
                                    ),

                                    const Divider(height: 20),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: FilledButton.icon(
                                            onPressed: () {
                                              _firestore
                                                  .collection("rdvs")
                                                  .doc(items[index].id)
                                                  .update({'status': 'annulé'});
                                              _firestore
                                                  .collection("notifications")
                                                  .add({
                                                    'expéditeur_uid':
                                                        _auth.currentUser!.uid,
                                                    'récepteur_uid':
                                                        items[index].clientUid,
                                                    'type': 'annulation',
                                                    'titre':
                                                        'Rendez-vous annulé',
                                                    'contenu':
                                                        'Votre rendez-vous avec ${items[index].prestataireUsername} a été annulé.',
                                                    'date': Timestamp.now(),
                                                  });
                                            },
                                            style: FilledButton.styleFrom(
                                              backgroundColor: Colors
                                                  .red
                                                  .shade200
                                                  .withAlpha(50),
                                            ),
                                            label: const Text(
                                              'Refuser',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            icon: const FaIcon(
                                              FontAwesomeIcons.xmark,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 150,
                                          child: FilledButton.icon(
                                            onPressed: () {
                                              _firestore
                                                  .collection("rdvs")
                                                  .doc(items[index].id)
                                                  .update({
                                                    'status': 'confirmé',
                                                  });
                                              _firestore
                                                  .collection("notifications")
                                                  .add({
                                                    'expéditeur_uid':
                                                        _auth.currentUser!.uid,
                                                    'récepteur_uid':
                                                        items[index].clientUid,
                                                    'type': 'confirmation',
                                                    'titre':
                                                        'Rendez-vous confirmé',
                                                    'contenu':
                                                        'Votre rendez-vous avec ${items[index].prestataireUsername} a été confirmé.',
                                                    'date': Timestamp.now(),
                                                  });
                                            },
                                            style: FilledButton.styleFrom(
                                              backgroundColor: Colors
                                                  .green
                                                  .shade200
                                                  .withAlpha(50),
                                            ),
                                            label: const Text(
                                              'Accepter',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            icon: const FaIcon(
                                              FontAwesomeIcons.check,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            );
                          }, childCount: items.length),
                        ),
                      ),
                    ],
                  );
                },
              ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
