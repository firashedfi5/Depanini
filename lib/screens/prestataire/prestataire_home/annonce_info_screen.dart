import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/post_model.dart';
import 'package:depanini/screens/commun/chat_screen.dart';
import 'package:depanini/widgets/image_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class AnnonceInfoScreen extends StatefulWidget {
  final String id;
  const AnnonceInfoScreen({super.key, required this.id});

  @override
  State<AnnonceInfoScreen> createState() => _AnnonceInfoScreenState();
}

class _AnnonceInfoScreenState extends State<AnnonceInfoScreen> {
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
      // dev.log("UID: $clientUid");

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
    try {
      final user = _auth.currentUser!;

      final userDoc =
          await _firestore.collection("prestataires").doc(user.uid).get();
      final userData = userDoc.data();
      if (userData == null || !userData.containsKey('Nom d\'utilisateur')) {
        throw Exception("Nom d'utilisateur non trouvé pour l'utilisateur");
      }
      final username = userData['Nom d\'utilisateur'];

      if (_reportController.text.isEmpty && mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Veuillez entrer un message.',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFFB00020),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Signalement envoyé.",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      dev.log("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de l\'envoi du rapport : $e',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFFB00020),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // **********************************
  void _submitProposal() async {
    try {
      final user = _auth.currentUser!;

      final userDoc =
          await _firestore.collection("prestataires").doc(user.uid).get();
      final userData = userDoc.data();
      if (userData == null || !userData.containsKey('Nom d\'utilisateur')) {
        throw Exception("Nom d'utilisateur non trouvé pour l'utilisateur");
      }
      final username = userData['Nom d\'utilisateur'];
      final profilPicture = userData['Photo de profile'];
      final averageRating = userData['averageRating'];

      final annonceRef = _firestore
          .collection('annonces')
          .doc(widget.id)
          .collection('propositions')
          .doc(user.email);

      await annonceRef.set({
        'date': Timestamp.now(),
        'username': username,
        'prestataire_email': user.email,
        'prestataire_uid': user.uid,
        'prestataire_photo': profilPicture,
        'prestataire_averageRating': averageRating,
      });
      await _firestore.collection("notifications").add({
        'expéditeur_uid': _auth.currentUser!.uid,
        'récepteur_uid': clientUid,
        'type': 'proposition',
        'titre': 'Nouvelle proposition reçue',
        'contenu':
            '$username souhaite vous proposer ses services pour résoudre votre problème.',
        'date': Timestamp.now(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Proposition envoyé.",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      dev.log("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de l\'envoi du propostion : $e',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFFB00020),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  // **********************************

  @override
  void dispose() {
    super.dispose();
    _reportController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Description d\'annonce')),
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
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 100,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: 4,
                              separatorBuilder:
                                  (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, imgIndex) {
                                final images = [
                                  snapshot.data!.image1,
                                  snapshot.data!.image2,
                                  snapshot.data!.image3,
                                  snapshot.data!.image4,
                                ];
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ImageContainer(
                                    height: 65,
                                    width: 85,
                                    imageUrl: images[imgIndex],
                                    // placeholder: Icons.photo_library_outlined,
                                  ),
                                );
                              },
                            ),
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
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 40),
                      ),
                      onPressed: _submitProposal,
                      child: const Text('Proposer un offre'),
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
                              child: CachedNetworkImage(
                                key: ValueKey(snapshot.data!.profilPicture),
                                imageUrl: snapshot.data!.profilPicture,
                                placeholder:
                                    (context, url) => const SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: CircularProgressIndicator(),
                                    ),
                                errorWidget:
                                    (context, url, error) => const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
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
                            decoration: const InputDecoration(
                              hintText: 'Décrivez le problème...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(12),
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
