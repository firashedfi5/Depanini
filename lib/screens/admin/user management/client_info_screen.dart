import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/client_account_model.dart';
import 'package:depanini/screens/admin/user%20management/client/cl_posts_screen.dart';
import 'package:depanini/screens/admin/user%20management/client/cl_rdv_screen.dart';
import 'package:depanini/screens/admin/user%20management/client/cl_reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

final _firestore = FirebaseFirestore.instance;

class ClientInfoScreen extends StatefulWidget {
  final ClientModel clientData;

  const ClientInfoScreen({super.key, required this.clientData});

  @override
  State<ClientInfoScreen> createState() => _ClientInfoScreenState();
}

class _ClientInfoScreenState extends State<ClientInfoScreen> {
  // *********************************
  // Functions to disable and enable user
  // These functions call the Cloud Function to disable or enable a user
  Future<void> disableUser(String uid) async {
    final url = Uri.parse(
      'https://us-central1-depanini-3304e.cloudfunctions.net/userManagement/disableUser',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'uid': uid}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // ✅ Now it's JSON
      if (data['success'] == true) {
        dev.log("User disabled");
      } else {
        dev.log("Failed: ${data['error']}");
      }
    } else {
      dev.log("Server error: ${response.body}"); // <- add this for debugging
    }
  }

  Future<void> enableUser(String uid) async {
    final url = Uri.parse(
      'https://us-central1-depanini-3304e.cloudfunctions.net/userManagement/enableUser',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'uid': uid}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // ✅ Now it's JSON
      if (data['success'] == true) {
        dev.log("User enabled");
      } else {
        dev.log("Failed: ${data['error']}");
      }
    } else {
      dev.log("Server error: ${response.body}"); // <- add this for debugging
    }
  }
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
                      child: CachedNetworkImage(
                        key: ValueKey(widget.clientData.profilPicture!),
                        imageUrl: widget.clientData.profilPicture!,
                        placeholder:
                            (context, url) => const SizedBox(
                              height: 100,
                              width: 100,
                              child: CircularProgressIndicator(),
                            ),
                        errorWidget:
                            (context, url, error) =>
                                const Icon(Icons.error, color: Colors.red),
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
                              StreamBuilder<DocumentSnapshot>(
                                stream:
                                    FirebaseFirestore.instance
                                        .collection('clients')
                                        .doc(
                                          widget.clientData.uid,
                                        ) // Make sure `uid` exists in `clientData`
                                        .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }

                                  if (!snapshot.hasData ||
                                      !snapshot.data!.exists) {
                                    return const Text("User not found");
                                  }

                                  final data =
                                      snapshot.data!.data()
                                          as Map<String, dynamic>;
                                  final status =
                                      data['Status'] as String? ?? 'Inconnu';
                                  final isActive = status == "Activé";

                                  return Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: (isActive
                                              ? Colors.green
                                              : Colors.red)
                                          .shade200
                                          .withAlpha(50),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      isActive ? "Activé" : "Désactivé",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium!.copyWith(
                                        color:
                                            isActive
                                                ? Colors.green
                                                : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
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
                          const SizedBox(height: 8),
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
                          const SizedBox(height: 8),
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
                        onPressed: () {
                          dev.log('Suspending user: ${widget.clientData.uid}');
                          disableUser(widget.clientData.uid!);
                          _firestore
                              .collection('clients')
                              .doc(widget.clientData.uid)
                              .update({'Status': 'Désactivé'});
                        },
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        icon: const Icon(Icons.thumb_up, size: 20),
                        label: const Text('Réactiver'),
                        onPressed: () {
                          dev.log(
                            'Reactivating user: ${widget.clientData.uid}',
                          );
                          enableUser(widget.clientData.uid!);
                          _firestore
                              .collection('clients')
                              .doc(widget.clientData.uid)
                              .update({'Status': 'Activé'});
                        },
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
                          const SizedBox(width: 8),
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
                          const SizedBox(width: 8),
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
                          const SizedBox(width: 8),
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
