import 'dart:convert';
import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/provider_account_model.dart';
import 'package:depanini/screens/admin/user%20management/prestataire/pr_feedback_screen.dart';
import 'package:depanini/screens/admin/user%20management/prestataire/pr_rdv_screen.dart';
import 'package:depanini/screens/admin/user%20management/prestataire/pr_reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

final _firestore = FirebaseFirestore.instance;

class PrestataireInfoScreen extends StatefulWidget {
  final ProviderAccountModel providerData;

  const PrestataireInfoScreen({super.key, required this.providerData});

  @override
  State<PrestataireInfoScreen> createState() => _PrestataireInfoScreenState();
}

class _PrestataireInfoScreenState extends State<PrestataireInfoScreen> {
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

  Stream<int> _rdvCountStream() {
    return _firestore
        .collection('rdvs')
        .where('prestataire_uid', isEqualTo: widget.providerData.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> _feedbackCountStream() {
    return _firestore
        .collection('prestataires')
        .doc(widget.providerData.uid)
        .collection('feedbacks')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> _reportCountStream() {
    return _firestore
        .collection('prestataires')
        .doc(widget.providerData.uid)
        .collection('reports')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informations du prestataire')),
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
                        widget.providerData.profilPicture,
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
                            widget.providerData.username,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.providerData.role,
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
                                        .collection('prestataires')
                                        .doc(
                                          widget.providerData.uid,
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
                                  text: widget.providerData.phoneNumber,
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
                                  text: widget.providerData.email,
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
                                    widget.providerData.inscritLe.toDate(),
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
                                  text: widget.providerData.localisation,
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
                      Text.rich(
                        TextSpan(
                          text: 'Description: ',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ), // Default style
                          children: [
                            TextSpan(
                              text: widget.providerData.description,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          text: 'Diplôme: ',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ), // Default style
                          children: [
                            TextSpan(
                              text: widget.providerData.diplome,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          text: 'Domaine: ',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ), // Default style
                          children: [
                            TextSpan(
                              text: widget.providerData.domaine,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                          disableUser(widget.providerData.uid);
                          _firestore
                              .collection('prestataires')
                              .doc(widget.providerData.uid)
                              .update({'Status': 'Désactivé'});
                        },
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        icon: const Icon(Icons.thumb_up, size: 20),
                        label: const Text('Réactiver'),
                        onPressed: () {
                          enableUser(widget.providerData.uid);
                          _firestore
                              .collection('prestataires')
                              .doc(widget.providerData.uid)
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
                              (context) => PrReportsScreen(
                                uid: widget.providerData.uid,
                                username: widget.providerData.username,
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
                        icon: const Icon(Icons.feedback, size: 20),
                        label: const Text('Voir Feedbacks'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => PrFeedbackScreen(
                                    uid: widget.providerData.uid,
                                    username: widget.providerData.username,
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
                                  (context) => PrRdvScreen(
                                    uid: widget.providerData.uid,
                                    username: widget.providerData.username,
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
                            Icons.feedback,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          StreamBuilder<int>(
                            stream: _feedbackCountStream(),
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
                                  text: 'Nombre de feedbacks: ',
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
