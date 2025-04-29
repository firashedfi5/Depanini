import 'dart:convert';
import 'dart:developer' as dev;

import 'package:depanini/models/rdv_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final _auth = FirebaseAuth.instance;

class ClientIncomingAppointment extends StatefulWidget {
  const ClientIncomingAppointment({super.key});

  @override
  State<ClientIncomingAppointment> createState() =>
      _ClientIncomingAppointmentState();
}

class _ClientIncomingAppointmentState extends State<ClientIncomingAppointment> {
  @override
  void initState() {
    super.initState();
    _loadRdvs();
  }

  // *******************************
  Future<List<RdvModel>> _loadRdvs() async {
    final url = Uri.http(
      '10.0.2.2:3300',
      'rdvs/${_auth.currentUser!.uid}/confirmé',
    ); // Virtual Device: 10.0.2.2 - Actual Device: 192.168.1.11 (ipconfig -> IPv4)

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception(
        'Echec de récupération des données. Veuillez réessayer plus tard.',
      );
    }

    dev.log(response.statusCode.toString());

    // Decode the JSON response correctly as a List
    final List<dynamic> listData = json.decode(response.body);

    final List<RdvModel> loadedRdvs =
        listData.map((rdv) {
          return RdvModel(
            id: rdv["id"],
            clientUid: rdv["client_uid"],
            prestataireUid: rdv["prestataire_uid"],
            clientUsername: rdv["client_username"],
            prestataireUsername: rdv["prestataire_username"],
            service: rdv["service"],
            date: rdv["date"],
            heure: rdv["heure"],
          );
        }).toList();

    return loadedRdvs;
  }
  // *******************************

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: FutureBuilder(
          future: _loadRdvs(),
          builder:
              (context, snapshot) => Builder(
                builder: (context) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No items found.'));
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
                              color: Colors.orange.withValues(alpha: 0.7),
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
                                  Text(items[index].date),
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
