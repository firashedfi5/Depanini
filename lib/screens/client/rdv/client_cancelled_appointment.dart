import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/rdv_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class ClientCancelledAppointment extends StatefulWidget {
  const ClientCancelledAppointment({super.key});

  @override
  State<ClientCancelledAppointment> createState() =>
      _ClientCancelledAppointmentState();
}

class _ClientCancelledAppointmentState
    extends State<ClientCancelledAppointment> {
  // *******************************
  Stream<List<RdvModel>> getCancelledRdvsStream() {
    return _firestore
        .collection('rdvs')
        .where('client_uid', isEqualTo: _auth.currentUser!.uid)
        .where('status', isEqualTo: 'annulé')
        .orderBy('createdAt', descending: true) // Note: use correct field name
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
          stream: getCancelledRdvsStream(),
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
                        'Aucune réservation annulé',
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
                              color: Colors.red.withValues(alpha: 0.7),
                              // Theme.of(context).brightness ==
                              //         Brightness.dark
                              //     ? Theme.of(context)
                              //         .colorScheme
                              //         .surfaceContainerHighest
                              //         .withAlpha(120)
                              //     : Theme.of(
                              //       context,
                              //     ).colorScheme.surfaceContainerHighest,
                              child: Column(
                                children: [
                                  Text(items[index].prestataireUsername),
                                  Text(items[index].service),
                                  Text(
                                    DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(items[index].date),
                                  ),
                                  Text(items[index].heure),
                                ],
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
