import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/rdv_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class ProviderCompletedAppointment extends StatefulWidget {
  const ProviderCompletedAppointment({super.key});

  @override
  State<ProviderCompletedAppointment> createState() =>
      _ProviderCompletedAppointmentState();
}

class _ProviderCompletedAppointmentState
    extends State<ProviderCompletedAppointment> {
  // *******************************
  Stream<List<RdvModel>> getCompletedRdvsStream() {
    return _firestore
        .collection('rdvs')
        .where('prestataire_uid', isEqualTo: _auth.currentUser!.uid)
        .where('status', isEqualTo: 'completé')
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
                  prestataireUid: data['prestataire_uid'],
                  prestataireUsername: data['prestataire_username'],
                  prestataireProfilePicture:
                      data['prestataire_profile_picture'],
                  service: data['service'],
                  date: (data['date'] as Timestamp).toDate(),
                  heure: data['heure'],
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
          stream: getCompletedRdvsStream(),
          builder:
              (context, snapshot) => Builder(
                builder: (context) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucune réservation completé',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
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
                        padding: EdgeInsets.all(0),
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
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundImage:
                                              items[index]
                                                      .clientProfilePicture
                                                      .isNotEmpty
                                                  ? NetworkImage(
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
                                        Spacer(),
                                        Container(
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade200
                                                .withAlpha(50),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Text(
                                            'Completé',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium!.copyWith(
                                              color: Colors.blue,
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
                                    const SizedBox(height: 12),
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
        SizedBox(width: 6),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
