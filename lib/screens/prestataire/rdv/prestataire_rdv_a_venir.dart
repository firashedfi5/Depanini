import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/place.dart';
import 'package:depanini/models/rdv_model.dart';
import 'package:depanini/screens/commun/map.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class PrestataireRdvAVenir extends StatefulWidget {
  const PrestataireRdvAVenir({super.key});

  @override
  State<PrestataireRdvAVenir> createState() => _PrestataireRdvAVenirState();
}

class _PrestataireRdvAVenirState extends State<PrestataireRdvAVenir> {
  // *Tfetchi ken les RDV eli status mte3hom confirmé
  Stream<List<RdvModel>> getIncomingRdvsStream() {
    return _firestore
        .collection('rdvs')
        .where('prestataire_uid', isEqualTo: _auth.currentUser!.uid)
        .where('status', isEqualTo: 'confirmé')
        .orderBy('date', descending: false)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: StreamBuilder(
          stream: getIncomingRdvsStream(),
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
                      child: Text('Aucune réservation confirmé'),
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
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text(
                                    //   items[index].prestataireLocation.longitude
                                    //       .toString(),
                                    // ),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundImage:
                                              items[index]
                                                      .clientProfilePicture
                                                      .isNotEmpty
                                                  ? CachedNetworkImageProvider(
                                                    items[index]
                                                        .clientProfilePicture,
                                                    cacheKey:
                                                        items[index]
                                                            .clientProfilePicture,
                                                  )
                                                  : null,
                                          child:
                                              items[index]
                                                      .clientProfilePicture
                                                      .isEmpty
                                                  ? const Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                  )
                                                  : null,
                                        ),
                                        const SizedBox(width: 16),
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
                                            color: Colors.green.shade200
                                                .withAlpha(50),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Text(
                                            'Confirmé',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium!.copyWith(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
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
                                    // const SizedBox(height: 12),
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
                                              'Annulé',
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
                                            onPressed:
                                                () => _firestore
                                                    .collection("rdvs")
                                                    .doc(items[index].id)
                                                    .update({
                                                      'status': 'completé',
                                                    }),
                                            style: FilledButton.styleFrom(
                                              backgroundColor: Colors
                                                  .blue
                                                  .shade200
                                                  .withAlpha(50),
                                            ),
                                            label: const Text(
                                              'Terminé',
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            icon: const FaIcon(
                                              FontAwesomeIcons.check,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.center,
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          fixedSize: const Size(170, 30),
                                        ),
                                        icon: const Icon(Icons.directions),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder:
                                                  // *Thezek lel Map screen
                                                  (context) => MapScreen(
                                                    // *Lezem n3adilha localisation mte3 l current user
                                                    location: PlaceLocation(
                                                      address:
                                                          items[index]
                                                              .prestataireLocation
                                                              .address,
                                                      latitude:
                                                          items[index]
                                                              .prestataireLocation
                                                              .latitude,
                                                      longitude:
                                                          items[index]
                                                              .prestataireLocation
                                                              .longitude,
                                                    ),
                                                    isSelecting:
                                                        false, // *Maynajemch ya5tar position fel map
                                                    isDrectionning:
                                                        true, // *Bech twarih tri9
                                                    // *Lezem n3adilha localisation mte3 l other users
                                                    othersLocations: [
                                                      PlaceLocation(
                                                        address:
                                                            items[index]
                                                                .clientLocation
                                                                .address,
                                                        latitude:
                                                            items[index]
                                                                .clientLocation
                                                                .latitude,
                                                        longitude:
                                                            items[index]
                                                                .clientLocation
                                                                .longitude,
                                                      ),
                                                    ],
                                                    prestataireInfo: const [],
                                                    clientUsername:
                                                        items[index]
                                                            .clientUsername,
                                                  ),
                                            ),
                                          );
                                        },
                                        label: const Text('Voir l’itinéraire'),
                                      ),
                                    ),
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
