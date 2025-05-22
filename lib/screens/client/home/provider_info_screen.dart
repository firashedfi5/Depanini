import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depanini/models/feedback_model.dart';
import 'package:depanini/models/provider_account_model.dart';
import 'package:depanini/screens/client/rdv/schedule_appointment_screen.dart';
import 'package:depanini/screens/common/chat_screen.dart';
import 'package:depanini/widgets/feedback.dart';
import 'package:depanini/widgets/image_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'dart:developer' as dev;

final _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class ProviderInfoScreen extends StatefulWidget {
  const ProviderInfoScreen({super.key, required this.email, required this.uid});
  final String uid;
  final String email;

  @override
  State<ProviderInfoScreen> createState() => _ProviderInfoScreenState();
}

class _ProviderInfoScreenState extends State<ProviderInfoScreen> {
  Future<List<FeedbackModel>> _feedbackList = Future.value([]);
  @override
  void initState() {
    super.initState();
    _loadPreviousRating();
    _feedbackList = fetchFeedbacks();
  }

  double rating = 0;
  // ***********Rating Method***************
  void _submitRating() async {
    try {
      final user = _auth.currentUser!;
      final ratingRef = _firestore
          .collection('prestataires')
          .doc(widget.uid)
          .collection('ratings')
          .doc(user.email);

      await ratingRef.set({
        'ratedAt': Timestamp.now(),
        'client_uid': user.uid,
        'client_email': user.email,
        'rating': rating,
      });

      // Recalculate average
      final ratingsSnapshot =
          await _firestore
              .collection('prestataires')
              .doc(widget.uid)
              .collection('ratings')
              .get();

      double total = 0;
      for (var doc in ratingsSnapshot.docs) {
        total += (doc.data()['rating'] ?? 0).toDouble();
      }

      double avgRating = total / ratingsSnapshot.docs.length;

      // Save average to main doc
      await _firestore.collection('prestataires').doc(widget.uid).update({
        'averageRating': avgRating,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Évaluation enregistrée.",
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
              'Erreur lors de l\'envoi de l\'avis : $e',
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

  // ****************************************
  Future<void> _loadPreviousRating() async {
    final user = _auth.currentUser!;
    final ratingDoc =
        await _firestore
            .collection('prestataires')
            .doc(widget.uid)
            .collection('ratings')
            .doc(user.email)
            .get();

    if (ratingDoc.exists) {
      setState(() {
        rating = (ratingDoc.data()?['rating'] ?? 0).toDouble();
      });
    }
  }

  // ***********Rating Method***************

  // ***********Feedback Method***************
  final TextEditingController _feedbackController = TextEditingController();

  void _submitFeedback() async {
    try {
      final user = _auth.currentUser!;

      final userDoc =
          await _firestore.collection("clients").doc(user.uid).get();
      final userData = userDoc.data();
      if (userData == null || !userData.containsKey('Nom d\'utilisateur')) {
        throw Exception("Nom d'utilisateur non trouvé pour l'utilisateur");
      }
      final username = userData['Nom d\'utilisateur'];

      if (_feedbackController.text.isEmpty && mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Veuillez entrer votre avis.',
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
          .collection('prestataires')
          .doc(widget.uid)
          .collection('feedbacks')
          .doc(user.email);

      await feedbackRef.set({
        'date': Timestamp.now(),
        'username': username,
        'client_email': user.email,
        'comment': _feedbackController.text,
      });
      _feedbackController.clear();

      _firestore.collection("notifications").add({
        'expéditeur_uid': _auth.currentUser!.uid,
        'récepteur_uid': widget.uid,
        'type': 'review',
        'titre': 'Nouvel avis reçu',
        'contenu': 'Vous avez reçu un nouvel avis de la part de $username.',
        'date': Timestamp.now(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Avis envoyé.",
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
              'Erreur lors de l\'envoi de l\'avis : $e',
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

  // *****************************************
  final TextEditingController _reportController = TextEditingController();
  void _submitReport() async {
    try {
      final user = _auth.currentUser!;

      final userDoc =
          await _firestore.collection("clients").doc(user.uid).get();
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
          .collection('prestataires')
          .doc(widget.uid)
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
        ScaffoldMessenger.of(context).clearSnackBars();
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
        ScaffoldMessenger.of(context).clearSnackBars();
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

  // *****************************************
  @override
  void dispose() {
    super.dispose();
    _feedbackController.dispose();
    _reportController.dispose();
  }

  Future<List<FeedbackModel>> fetchFeedbacks() async {
    // final user = _auth.currentUser!;
    final feedbackRef =
        await _firestore
            .collection('prestataires')
            .doc(widget.uid)
            .collection('feedbacks')
            .orderBy('date', descending: true)
            .get();

    final snapshot =
        feedbackRef.docs
            .map((doc) => FeedbackModel.fromSnapshot(doc))
            // .where((feedback) => feedback.clientEmail != user.email)
            .toList();

    return snapshot;
  }

  // ***********Feedback Method***************

  // *********Phone Call*****************
  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not make the phone call';
    }
  }

  // *********Phone Call*****************
  Future<ProviderAccountModel> getUserData() async {
    final data =
        await _firestore
            .collection("prestataires")
            .where("Email", isEqualTo: widget.email)
            .get();
    final snapshot =
        data.docs.map((doc) => ProviderAccountModel.fromSnapshot(doc)).single;
    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informations du prestataire')),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.all(8),
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
                            snapshot.data!.profilPicture,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                snapshot.data!.username,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                snapshot.data!.description,
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              // Text('Diplôme: ${snapshot.data!.diplome}'),
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
                                      text: snapshot.data!.diplome,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text.rich(
                                TextSpan(
                                  text: 'Experience: ',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ), // Default style
                                  children: [
                                    TextSpan(
                                      text: snapshot.data!.experience,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Notes: ',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const Icon(Icons.star, color: Colors.amber),
                                  const SizedBox(width: 6),
                                  Text(
                                    snapshot.data!.averageRating
                                        .toStringAsFixed(2),
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton.icon(
                            icon: const Icon(Icons.call, size: 20),
                            label: const Text('Appeler'),
                            onPressed:
                                () => _makePhoneCall(
                                  '+216${snapshot.data!.phoneNumber}',
                                ),
                          ),
                          const SizedBox(width: 16),
                          FilledButton.icon(
                            icon: const Icon(Icons.message, size: 20),
                            label: const Text('Message'),
                            onPressed:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ChatScreen(
                                          receiverEmail: snapshot.data!.email,
                                          receiverUsername:
                                              snapshot.data!.username,
                                          receiverProfilPicture:
                                              snapshot.data!.profilPicture,
                                        ),
                                  ),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        icon: const Icon(Icons.calendar_month, size: 20),
                        label: const Text('Demander un rendez-vous'),
                        onPressed:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => ScheduleAppointmentScreen(
                                      prestataireUid: snapshot.data!.uid,
                                      prestataireUsername:
                                          snapshot.data!.username,
                                      prestataireProfilePicture:
                                          snapshot.data!.profilPicture,
                                      prestataireLocation:
                                          snapshot.data!.localisation,
                                      prestataireLatLong: [
                                        snapshot.data!.latitude,
                                        snapshot.data!.longitude,
                                      ],
                                      service: snapshot.data!.domaine,
                                    ),
                              ),
                            ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Portfolio
                  Card(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(
                              context,
                            ).colorScheme.secondaryContainer.withAlpha(100)
                            : Theme.of(context).colorScheme.secondaryContainer,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Portfolio',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 100,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: 4,
                              separatorBuilder:
                                  (_, __) => const SizedBox(width: 12),
                              itemBuilder:
                                  (context, index) => ImageContainer(
                                    height: 90,
                                    width: 120,
                                    imageUrl:
                                        [
                                          snapshot.data!.workPicture_1,
                                          snapshot.data!.workPicture_2,
                                          snapshot.data!.workPicture_3,
                                          snapshot.data!.workPicture_4,
                                        ][index],
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Rating Section
                  Card(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(
                              context,
                            ).colorScheme.secondaryContainer.withAlpha(100)
                            : Theme.of(context).colorScheme.secondaryContainer,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Donner une note',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          RatingBar.builder(
                            initialRating: rating,
                            minRating: 1,
                            itemCount: 5,
                            itemSize: 32,
                            allowHalfRating: true,
                            glow: true,
                            itemPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            itemBuilder:
                                (context, _) =>
                                    const Icon(Icons.star, color: Colors.amber),
                            onRatingUpdate: (value) => rating = value,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            // width: 210,
                            child: FilledButton.icon(
                              icon: const FaIcon(
                                FontAwesomeIcons.solidFloppyDisk,
                                size: 16,
                              ),
                              label: const Text('Enregistrer l\'évaluation'),
                              onPressed: _submitRating,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(double.minPositive, 48),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // New Feedback Section
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
                            'Avis',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          // Existing feedbacks list
                          SizedBox(
                            height: 125,
                            child: FutureBuilder<List<FeedbackModel>>(
                              future: _feedbackList,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Erreur: ${snapshot.error}'),
                                  );
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      'Aucun avis ajouté pour le moment',
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  physics: BouncingScrollPhysics(),
                                  itemCount: snapshot.data!.length,
                                  itemBuilder:
                                      (context, index) => FeedbackItem(
                                        feedback: snapshot.data![index],
                                        uid: widget.uid,
                                      ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _feedbackController,
                            decoration: const InputDecoration(
                              hintText: 'Écrivez votre avis...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(12),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _submitFeedback,
                            child: const Text('Soumettre'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

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
                            child: const Text('Soumettre'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
