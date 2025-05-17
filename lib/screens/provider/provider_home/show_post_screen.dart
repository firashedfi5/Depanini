import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/post_model.dart';
import 'package:depanini/screens/common/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class ShowPostScreen extends StatefulWidget {
  final String id;
  const ShowPostScreen({super.key, required this.id});

  @override
  State<ShowPostScreen> createState() => _ShowPostScreenState();
}

class _ShowPostScreenState extends State<ShowPostScreen> {
  late Future<PostModel> _annonceList;
  String? clientUid;
  @override
  void initState() {
    super.initState();
    _annonceList = _loadAnnonce();
  }

  // *********Phone Call*****************
  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not make the phone call';
    }
  }

  Future<PostModel> _loadAnnonce() async {
    try {
      final doc = await _firestore.collection('annonces').doc(widget.id).get();

      if (!doc.exists) {
        throw Exception('Aucune annonce trouvée.');
      }

      final data = doc.data()!;

      setState(() {
        clientUid = data["uid"];
      });
      dev.log("UID: $clientUid");

      return PostModel(
        postId: data["post_id"],
        email: data["email"],
        uid: data["uid"],
        username: data["username"],
        phoneNumber: data["phone_number"],
        profilPicture: data["profil_picture"],
        description: data["description"],
        service: data['service'],
        date: (data['date'] as Timestamp).toDate(),
        createdAt: data['createdAt'],
        image1: data["imageURL_1"],
        image2: data["imageURL_2"],
        image3: data["imageURL_3"],
        image4: data["imageURL_4"],
      );
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'annonce : $e');
    }
  }

  // **************Report**********
  final _reportController = TextEditingController();

  void _submitReport() async {
    final user = _auth.currentUser!;

    final userDoc =
        await _firestore.collection("prestataires").doc(user.uid).get();
    final userData = userDoc.data();
    if (userData == null || !userData.containsKey('Nom d\'utilisateur')) {
      throw Exception("Nom d'utilisateur non trouvé pour l'utilisateur");
    }
    final username = userData['Nom d\'utilisateur'];

    final feedbackRef = _firestore
        .collection('clients')
        .doc(clientUid)
        .collection('reports')
        .doc(user.email);

    await feedbackRef.set({
      'date': Timestamp.now(),
      'username': username,
      'client_email': user.email,
      'report': _reportController.text,
    });
    _reportController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _reportController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Description d\'annonce')),
      body: FutureBuilder(
        future: _annonceList,
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
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest.withAlpha(100)
                            : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.data!.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              // Domaine Info
                              Row(
                                children: [
                                  Icon(
                                    Icons.work_outline,
                                    size: 20,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Domaine',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                      ),
                                      Text(
                                        snapshot.data!.service,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(width: 24),
                              // Date Info
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Date',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                      ),
                                      Text(
                                        DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(snapshot.data!.date),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium!.copyWith(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest.withAlpha(100)
                            : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                    elevation: 2,
                    child: SizedBox(
                      height: 150,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                snapshot.data!.profilPicture,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    snapshot.data!.username,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    snapshot.data!.phoneNumber,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton.filled(
                                  icon: Icon(
                                    Icons.call,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  onPressed:
                                      () => _makePhoneCall(
                                        '+216${snapshot.data!.phoneNumber}',
                                      ),
                                  style: IconButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                IconButton.filled(
                                  icon: Icon(
                                    Icons.message,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  onPressed:
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => ChatScreen(
                                                receiverEmail:
                                                    snapshot.data!.email,
                                                receiverUsername:
                                                    snapshot.data!.username,
                                                receiverProfilPicture:
                                                    snapshot
                                                        .data!
                                                        .profilPicture,
                                              ),
                                        ),
                                      ),
                                  style: IconButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // New Reporting Section
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
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Signaler un abus',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _reportController,
                            decoration: InputDecoration(
                              hintText: 'Décrivez le problème...',
                              border: OutlineInputBorder(),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _submitReport,
                            // _submitReport,
                            child: const Text('Soumettre'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
