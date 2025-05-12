// import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/client_account_model.dart';
import 'package:depanini/screens/admin/user%20management/client/cl_posts_screen.dart';
import 'package:depanini/screens/admin/user%20management/client/cl_rdv_screen.dart';
import 'package:depanini/screens/admin/user%20management/client/cl_reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:cloud_functions/cloud_functions.dart';

final _firestore = FirebaseFirestore.instance;

class ClientInfoScreen extends StatefulWidget {
  final ClientModel clientData;

  const ClientInfoScreen({super.key, required this.clientData});

  @override
  State<ClientInfoScreen> createState() => _ClientInfoScreenState();
}

class _ClientInfoScreenState extends State<ClientInfoScreen> {
  // *********************************
  // Future<void> setUserDisabledStatus(String uid, bool disable) async {
  //   final callable = FirebaseFunctions.instance.httpsCallable(
  //     'setUserDisabledStatus',
  //   );
  //   try {
  //     final result = await callable.call({'uid': uid, 'disable': disable});
  //     dev.log('User status changed: ${result.data['status']}');
  //   } catch (e) {
  //     dev.log('Failed to change user status: $e');
  //   }
  // }
  // *********************************

  Stream<int> _postCountStream() {
    return _firestore
        .collection('annonces')
        .where('uid', isEqualTo: widget.clientData.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> _rdvCountStream() {
    return _firestore
        .collection('rdvs')
        .where('client_uid', isEqualTo: widget.clientData.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> _reportCountStream() {
    return _firestore
        .collection('clients')
        .doc(widget.clientData.uid)
        .collection('reports')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informations du client')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(
                          context,
                        ).colorScheme.secondaryContainer.withAlpha(100)
                        : Theme.of(context).colorScheme.secondaryContainer,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: Image.network(
                        widget.clientData.profilPicture!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            widget.clientData.username!,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.clientData.role!,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '•',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(width: 8),
                              // Status
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration:
                                    widget.clientData.status == "Activé"
                                        ? BoxDecoration(
                                          color: Colors.green.shade200
                                              .withAlpha(50),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        )
                                        : BoxDecoration(
                                          color: Colors.red.shade200.withAlpha(
                                            50,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                child: Text(
                                  widget.clientData.status == "Activé"
                                      ? "Activé"
                                      : "Désactivé",
                                  style:
                                      widget.clientData.status == "Activé"
                                          ? Theme.of(
                                            context,
                                          ).textTheme.titleMedium!.copyWith(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          )
                                          : Theme.of(
                                            context,
                                          ).textTheme.titleMedium!.copyWith(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              text: 'Numéro de téléphone: ',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ), // Default style
                              children: [
                                TextSpan(
                                  text: widget.clientData.phoneNumber!,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              text: 'Email: ',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ), // Default style
                              children: [
                                TextSpan(
                                  text: widget.clientData.email!,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text.rich(
                            textAlign: TextAlign.center,
                            TextSpan(
                              text: 'Inscrit le: ',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ), // Default style
                              children: [
                                TextSpan(
                                  text: DateFormat.yMMMd('fr_FR').format(
                                    widget.clientData.inscritLe!.toDate(),
                                  ),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text.rich(
                            textAlign: TextAlign.center,
                            TextSpan(
                              text: 'Adresse: ',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ), // Default style
                              children: [
                                TextSpan(
                                  text: widget.clientData.localisation!,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Action Buttons
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.icon(
                        icon: const Icon(Icons.back_hand, size: 20),
                        label: const Text('Suspendre'),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        icon: const Icon(Icons.thumb_up, size: 20),
                        label: const Text('Réactiver'),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    icon: const Icon(Icons.report, size: 20),
                    label: const Text('Voir signalements'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => ClReportsScreen(
                                uid: widget.clientData.uid!,
                                username: widget.clientData.username!,
                              ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.icon(
                        icon: const Icon(Icons.article, size: 20),
                        label: const Text('Voir annonces'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => ClPostsScreen(
                                    uid: widget.clientData.uid!,
                                    username: widget.clientData.username!,
                                  ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Voir rendez-vous'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => ClRdvScreen(
                                    uid: widget.clientData.uid!,
                                    username: widget.clientData.username!,
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Information Card
              Card(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(
                          context,
                        ).colorScheme.secondaryContainer.withAlpha(100)
                        : Theme.of(context).colorScheme.secondaryContainer,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.report,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 8),
                          StreamBuilder<int>(
                            stream: _reportCountStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Chargement...');
                              }

                              if (snapshot.hasError) {
                                return const Text('Erreur');
                              }

                              final count = snapshot.data ?? 0;
                              return Text.rich(
                                TextSpan(
                                  text: 'Nombre de signalements: ',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ), // Default style
                                  children: [
                                    TextSpan(
                                      text: count.toString(),
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.article,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 8),
                          StreamBuilder<int>(
                            stream: _postCountStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Chargement...');
                              }

                              if (snapshot.hasError) {
                                return const Text('Erreur');
                              }

                              final count = snapshot.data ?? 0;
                              return Text.rich(
                                TextSpan(
                                  text: 'Nombre d\'annonces: ',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ), // Default style
                                  children: [
                                    TextSpan(
                                      text: count.toString(),
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 8),
                          StreamBuilder<int>(
                            stream: _rdvCountStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Chargement...');
                              }

                              if (snapshot.hasError) {
                                return const Text('Erreur');
                              }

                              final count = snapshot.data ?? 0;
                              return Text.rich(
                                TextSpan(
                                  text: 'Nombre de rendez-vous: ',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ), // Default style
                                  children: [
                                    TextSpan(
                                      text: count.toString(),
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
