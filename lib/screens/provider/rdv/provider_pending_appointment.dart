import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/rdv_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class ProviderPendingAppointment extends StatefulWidget {
  const ProviderPendingAppointment({super.key});

  @override
  State<ProviderPendingAppointment> createState() =>
      _ProviderPendingAppointmentState();
}

class _ProviderPendingAppointmentState
    extends State<ProviderPendingAppointment> {
  // *******************************
  Stream<List<RdvModel>> getPendingRdvsStream() {
    return _firestore
        .collection('rdvs')
        .where('prestataire_uid', isEqualTo: _auth.currentUser!.uid)
        .where('status', isEqualTo: 'en_attente')
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
                  prestataireUid: data['prestataire_uid'],
                  prestataireUsername: data['prestataire_username'],
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
          stream: getPendingRdvsStream(),
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
                        'Aucune réservation en attente',
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
                              color: Colors.grey.withValues(alpha: 0.5),
                              child: Column(
                                children: [
                                  Text(items[index].clientUsername),
                                  Text(
                                    DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(items[index].date),
                                  ),
                                  Text(items[index].heure),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        width: 130,
                                        child: IconButton(
                                          onPressed:
                                              () => _firestore
                                                  .collection("rdvs")
                                                  .doc(items[index].id)
                                                  .update({'status': 'annulé'}),
                                          icon: FaIcon(
                                            FontAwesomeIcons.xmark,
                                            color: Colors.red,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 130,
                                        child: IconButton(
                                          onPressed:
                                              () => _firestore
                                                  .collection("rdvs")
                                                  .doc(items[index].id)
                                                  .update({
                                                    'status': 'confirmé',
                                                  }),
                                          icon: FaIcon(
                                            FontAwesomeIcons.check,
                                            color: Colors.green,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
